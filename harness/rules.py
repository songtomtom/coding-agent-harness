#!/usr/bin/env python3
"""CLAUDE.md 규칙 중 기계 판정이 가능한 것. 평가와 Hook 이 같이 쓴다.
사용: rules.py <root> <files...>  |  rules.py --text <path> [--fragment] < 내용
출력: "R-xx <file>:<line>: <설명>" 한 줄씩. fragment 모드는 파일 전체가 필요한 규칙을 건너뛴다."""
import re, sys, os

TOKENS = "libs/ui/src/tokens.ts"
in_apps_or_ui = lambda f: f.startswith("apps/") or (f.startswith("libs/ui/src/") and f != TOKENS)

def check(f, text, fragment=False, root="."):
    out = []
    def hit(rule, ln, msg): out.append(f"{rule} {f}:{ln}: {msg}")
    def scan(rule, pat, msg):
        for i, line in enumerate(text.splitlines(), 1):
            s = line.strip()
            if s.startswith(("//", "*", "/*")): continue
            if re.search(pat, line): hit(rule, i, msg)
    if not f.endswith((".ts", ".tsx")): return out
    is_test = ".test." in f
    if f != TOKENS:
        scan("R-01", r"['\"`]#[0-9a-fA-F]{3,8}\b", "색 값 하드코딩 (tokens 사용)")
    if in_apps_or_ui(f) and not is_test:
        scan("R-02", r"\b(padding|margin|gap|borderRadius|marginBottom|marginTop)\s*:\s*['\"]?\d", "간격·모서리 숫자 하드코딩 (tokens.space / tokens.radius)")
        scan("R-07", r"repeat\(\s*\d+\s*,", "열 수 하드코딩 (COLUMNS.length)")
    if f.startswith("apps/") and f.endswith(".tsx") and not is_test:
        scan("R-03", r"(>\s*[^<>{}\n]*[가-힣]|placeholder=\"[^\"]*[가-힣]|title=\"[^\"]*[가-힣])", "한글 리터럴 (t() 사용)")
    if f.startswith("apps/"):
        scan("R-04", r"from\s+['\"](\.\.?/)+[^'\"]*libs/", "상대 경로로 라이브러리 진입 (@board/* 별칭)")
    if f.startswith("libs/board-core/src/") and not is_test:
        scan("R-05", r"\b(window|document|localStorage|fetch)\b|from\s+['\"]react", "도메인은 DOM·저장소·React 를 모른다")
    scan("R-06", r"\bconsole\.log\(", "console.log 금지")
    if f.startswith("libs/ui/src/"):
        scan("R-10", r"\bvariant\b", "ui 컴포넌트에 모양 분기(variant) 금지")
    if "__tests__" in f: hit("R-11", 0, "__tests__ 폴더 금지 (대상 옆 .test)")
    # 파일 전체 판정
    if not fragment and f.startswith("libs/ui/src/") and f.endswith(".tsx") and not is_test and f != TOKENS:
        name = os.path.basename(f)[:-4]
        idx = os.path.join(root, "libs/ui/src/index.ts")
        if os.path.exists(idx) and name not in open(idx).read(): hit("R-09", 0, f"{name} 이 index.ts 에서 export 되지 않음")
        if not os.path.exists(os.path.join(root, f"libs/ui/src/{name}.test.tsx")): hit("R-09", 0, f"{name}.test.tsx 없음")
    return out

if __name__ == "__main__":
    a = sys.argv[1:]
    if a and a[0] == "--text":
        print("\n".join(check(a[1], sys.stdin.read(), "--fragment" in a)))
    else:
        root = a[0]; os.chdir(root); res = []
        for f in a[1:]:
            if os.path.isfile(f): res += check(f, open(f, encoding="utf-8", errors="ignore").read(), root=".")
        print("\n".join(res))
