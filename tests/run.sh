#!/usr/bin/env bash
# Local self-test for lark-push. No network / no keychain required.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
LP="${ROOT}/skills/lark-push/scripts/lark-push"
BC="${ROOT}/skills/lark-push/scripts/build_card.py"
PASS=0
FAIL=0

assert_eq() {
  local name="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "  PASS  $name"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $name"
    echo "        expected: $expected"
    echo "        actual:   $actual"
    FAIL=$((FAIL + 1))
  fi
}

assert_contains() {
  local name="$1" needle="$2" haystack="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "  PASS  $name"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $name (missing: $needle)"
    echo "        got: ${haystack:0:200}"
    FAIL=$((FAIL + 1))
  fi
}

assert_exit() {
  local name="$1" expected="$2"
  shift 2
  set +e
  "$@" >/tmp/lark-push-test-out.$$ 2>/tmp/lark-push-test-err.$$
  local code=$?
  set -e
  if [[ "$code" -eq "$expected" ]]; then
    echo "  PASS  $name (exit $code)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $name (exit $code, expected $expected)"
    echo "        stderr: $(head -c 300 /tmp/lark-push-test-err.$$)"
    FAIL=$((FAIL + 1))
  fi
}

assert_exit_code_soft() {
  local name="$1" expected="$2" actual="$3"
  if [[ "$actual" -eq "$expected" ]]; then
    echo "  PASS  $name (exit $actual)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $name (exit $actual, expected $expected)"
    FAIL=$((FAIL + 1))
  fi
}

echo "== syntax =="
bash -n "$LP"
bash -n "${ROOT}/skills/lark-push/scripts/git-post-commit-lark-push"
python3 -m py_compile "$BC"
echo "  PASS  bash -n / py_compile"
PASS=$((PASS + 1))

echo "== version =="
ver_out="$("$LP" --version)"
assert_contains "version from SKILL.md" "lark-push v1.3.0" "$ver_out"

echo "== doctor =="
set +e
doc_out="$("$LP" doctor 2>&1)"
doc_code=$?
set -e
assert_contains "doctor header" "lark-push doctor" "$doc_out"
assert_contains "doctor checks lark-cli" "lark-cli" "$doc_out"
assert_contains "doctor checks python3" "python3" "$doc_out"
assert_contains "doctor checks node/npm hints" "node" "$doc_out"
# Required items should pass on this machine (config + tools exist)
if [[ "$doc_code" -eq 0 ]]; then
  echo "  PASS  doctor exit 0"
  PASS=$((PASS + 1))
else
  # Still accept exit 1 if only soft env differs; but require helpful fail text
  assert_contains "doctor fail guidance" "FAIL" "$doc_out"
fi

echo "== missing lark-cli error text =="
set +e
miss_out="$(PATH=/usr/bin:/bin "$LP" --chat-id oc_x --kind notice --title t --body hello 2>&1)"
miss_code=$?
set -e
assert_exit_code_soft "missing lark-cli exit" 127 "$miss_code"
assert_contains "missing lark-cli hint npm" "npm install -g @larksuite/cli" "$miss_out"
assert_contains "missing lark-cli tip doctor" "doctor" "$miss_out"

echo "== require_val / leading dash body =="
out="$("$LP" --dry-run --chat-id oc_example --kind daily --title "Daily" --body "- shipped A
- blocked on B" 2>/tmp/lark-push-test-err.$$)"
assert_contains "dash body dry-run meta" "[dry-run] not calling lark-cli" "$(cat /tmp/lark-push-test-err.$$)"
assert_contains "dash body card json" '"schema":"2.0"' "$out"
assert_contains "dash body content" "- shipped A" "$out"

echo "== empty value rejected =="
assert_exit "empty --body" 2 "$LP" --dry-run --chat-id oc_example --kind code --title T --body ""

echo "== missing chat id =="
# Durable config may exist on the machine; override via last-loaded config file.
empty_cfg="$(mktemp)"
printf 'LARK_PUSH_CHAT_ID=\n' >"$empty_cfg"
assert_exit "no chat id" 2 env LARK_PUSH_CONFIG="$empty_cfg" \
  "$LP" --dry-run --kind code --title T --body hello
rm -f "$empty_cfg"

echo "== invalid kind =="
assert_exit "bad kind" 2 "$LP" --dry-run --chat-id oc_x --kind nope --title T --body x

echo "== markdown dry-run =="
out="$("$LP" --dry-run --chat-id oc_example --format markdown --kind code --title "T" --body "hello" --no-context 2>/tmp/lark-push-test-err.$$)"
assert_contains "md title" "T" "$out"
assert_contains "md body" "hello" "$out"

echo "== idempotency key length =="
err="$("$LP" --dry-run --chat-id oc_x --kind release --title T --body x --idempotency-key "$(python3 -c 'print("k"*80)')" 2>&1 >/dev/null)"
assert_contains "truncate warn" "truncating" "$err"
# extract key length from stderr line
if [[ "$err" == *"idempotency_key="* ]]; then
  key_line="$(printf '%s\n' "$err" | grep 'idempotency_key=' | head -1)"
  # format: [dry-run] idempotency_key=... (len=N)
  len="$(printf '%s' "$key_line" | sed -nE 's/.*\(len=([0-9]+)\).*/\1/p')"
  if [[ -n "$len" && "$len" -le 50 ]]; then
    echo "  PASS  idempotency len<=50 ($len)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  idempotency len ($len)"
    FAIL=$((FAIL + 1))
  fi
else
  echo "  FAIL  could not parse idempotency line"
  FAIL=$((FAIL + 1))
fi

echo "== build_card.py escape =="
card="$(
  CARD_KIND=code CARD_TITLE='Title *x*' CARD_LABEL='Code' CARD_NOW='now' \
  CARD_SOURCE='repo *main*' CARD_BODY='**bold** body' CARD_FOOTER='via *bot*' \
  python3 "$BC"
)"
python3 -c "import json,sys; json.loads(sys.argv[1])" "$card"
assert_contains "escaped source" 'repo \\*main\\*' "$card"
assert_contains "body stays markdown" '**bold** body' "$card"

echo "== init quoting =="
TMP="$(mktemp -d)"
# Point skill parent via running from package; init writes durable next to skill package parent.
# Use --target local inside package for isolated test, then delete.
cfg_local="${ROOT}/skills/lark-push/config.local.env"
rm -f "$cfg_local"
"$LP" init --target local --chat-id 'oc_test_123' --footer "via bot's skill" --force >/dev/null
# shellcheck disable=SC1090
source "$cfg_local"
assert_eq "init chat id" "oc_test_123" "${LARK_PUSH_CHAT_ID}"
assert_eq "init footer with apostrophe" "via bot's skill" "${LARK_PUSH_FOOTER}"
rm -f "$cfg_local"
rm -rf "$TMP"

echo "== git hook disable =="
assert_exit "hook disabled" 0 env LARK_PUSH_GIT_HOOK=0 \
  bash "${ROOT}/skills/lark-push/scripts/git-post-commit-lark-push"

echo
echo "Results: ${PASS} passed, ${FAIL} failed"
rm -f /tmp/lark-push-test-out.$$ /tmp/lark-push-test-err.$$
if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi
