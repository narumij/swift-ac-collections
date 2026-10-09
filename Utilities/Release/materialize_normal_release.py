#!/usr/bin/env python3
"""Materialize the normal build by partially evaluating one Swift flag.

Only Swift conditional-compilation directives are interpreted. Unknown conditions
are preserved, while COMPATIBLE_ATCODER_2025 is fixed to false.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import re
import sys


FLAG = "COMPATIBLE_ATCODER_2025"
DIRECTIVE = re.compile(r"^(?P<indent>\s*)#(?P<kind>if|elseif|else|endif)\b(?P<rest>.*)$")


@dataclass(frozen=True)
class Expr:
    value: bool | None
    text: str


def negate(expr: Expr) -> Expr:
    if expr.value is not None:
        return Expr(not expr.value, "true" if not expr.value else "false")
    if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*(?:\([^\n]*\))?", expr.text):
        return Expr(None, f"!{expr.text}")
    return Expr(None, f"!({expr.text})")


def combine(lhs: Expr, op: str, rhs: Expr) -> Expr:
    if op == "&&":
        if lhs.value is False or rhs.value is False:
            return Expr(False, "false")
        if lhs.value is True:
            return rhs
        if rhs.value is True:
            return lhs
    else:
        if lhs.value is True or rhs.value is True:
            return Expr(True, "true")
        if lhs.value is False:
            return rhs
        if rhs.value is False:
            return lhs
    if lhs.value is not None and rhs.value is not None:
        value = lhs.value and rhs.value if op == "&&" else lhs.value or rhs.value
        return Expr(value, "true" if value else "false")
    return Expr(None, f"{lhs.text} {op} {rhs.text}")


class ExpressionParser:
    def __init__(self, source: str):
        self.source = source.strip()
        self.index = 0

    def parse(self) -> Expr:
        expression = self.parse_or()
        self.skip_spaces()
        if self.index != len(self.source):
            raise ValueError(f"unsupported expression tail: {self.source[self.index:]}")
        return expression

    def parse_or(self) -> Expr:
        expression = self.parse_and()
        while self.take("||"):
            expression = combine(expression, "||", self.parse_and())
        return expression

    def parse_and(self) -> Expr:
        expression = self.parse_unary()
        while self.take("&&"):
            expression = combine(expression, "&&", self.parse_unary())
        return expression

    def parse_unary(self) -> Expr:
        self.skip_spaces()
        if self.take("!"):
            return negate(self.parse_unary())
        if self.take("("):
            expression = self.parse_or()
            if not self.take(")"):
                raise ValueError("missing closing parenthesis")
            return expression
        atom = self.parse_atom()
        if atom == FLAG:
            return Expr(False, "false")
        if atom == "true":
            return Expr(True, "true")
        if atom == "false":
            return Expr(False, "false")
        return Expr(None, atom)

    def parse_atom(self) -> str:
        self.skip_spaces()
        start = self.index
        depth = 0
        while self.index < len(self.source):
            if depth == 0 and (
                self.source.startswith("&&", self.index)
                or self.source.startswith("||", self.index)
                or self.source[self.index] == ")"
            ):
                break
            character = self.source[self.index]
            if character == "(":
                depth += 1
            elif character == ")":
                if depth == 0:
                    break
                depth -= 1
            self.index += 1
        atom = self.source[start:self.index].strip()
        if not atom:
            raise ValueError("expected expression atom")
        return atom

    def skip_spaces(self) -> None:
        while self.index < len(self.source) and self.source[self.index].isspace():
            self.index += 1

    def take(self, token: str) -> bool:
        self.skip_spaces()
        if self.source.startswith(token, self.index):
            self.index += len(token)
            return True
        return False


@dataclass
class Branch:
    condition: Expr | None
    indent: str
    body: list[str]


def parse_condition(text: str, path: Path, line_number: int) -> Expr:
    try:
        return ExpressionParser(text).parse()
    except ValueError as error:
        raise ValueError(f"{path}:{line_number}: {error}: {text.strip()}") from error


def transform_lines(lines: list[str], path: Path) -> list[str]:
    output, index, stop = transform_region(lines, 0, path, set())
    if stop is not None or index != len(lines):
        raise ValueError(f"{path}: unmatched conditional-compilation directive")
    if output != lines:
        while len(output) > 1 and not output[-1].strip() and not output[-2].strip():
            output.pop()
    return output


def transform_region(
    lines: list[str], index: int, path: Path, stops: set[str]
) -> tuple[list[str], int, str | None]:
    output: list[str] = []
    while index < len(lines):
        match = DIRECTIVE.match(lines[index])
        if match and match.group("kind") in stops:
            return output, index, match.group("kind")
        if not match or match.group("kind") != "if":
            output.append(lines[index])
            index += 1
            continue

        branches: list[Branch] = []
        condition = parse_condition(match.group("rest"), path, index + 1)
        indent = match.group("indent")
        index += 1
        while True:
            body, index, stop = transform_region(lines, index, path, {"elseif", "else", "endif"})
            branches.append(Branch(condition, indent, body))
            if stop == "elseif":
                next_match = DIRECTIVE.match(lines[index])
                assert next_match is not None
                condition = parse_condition(next_match.group("rest"), path, index + 1)
                indent = next_match.group("indent")
                index += 1
                continue
            if stop == "else":
                next_match = DIRECTIVE.match(lines[index])
                assert next_match is not None
                index += 1
                body, index, stop = transform_region(lines, index, path, {"endif"})
                branches.append(Branch(None, next_match.group("indent"), body))
            if stop != "endif":
                raise ValueError(f"{path}: unterminated #if")
            index += 1
            output.extend(render_branches(branches))
            break
    return output, index, None


def render_branches(branches: list[Branch]) -> list[str]:
    remaining: list[Branch] = []
    for branch in branches:
        if branch.condition is not None and branch.condition.value is False:
            continue
        remaining.append(branch)
        if branch.condition is None or branch.condition.value is True:
            break

    if not remaining:
        return []
    if remaining[0].condition is None or remaining[0].condition.value is True:
        return remaining[0].body

    output: list[str] = []
    for position, branch in enumerate(remaining):
        if branch.condition is None:
            output.append(f"{branch.indent}#else\n")
        else:
            keyword = "if" if position == 0 else "elseif"
            output.append(f"{branch.indent}#{keyword} {branch.condition.text}\n")
        output.extend(branch.body)
    output.append(f"{remaining[0].indent}#endif\n")
    return output


def swift_files(paths: list[Path]) -> list[Path]:
    result: list[Path] = []
    for path in paths:
        if path.is_dir():
            result.extend(
                candidate
                for candidate in sorted(path.rglob("*.swift"))
                if not any(part in {".build", ".git"} for part in candidate.parts)
            )
        elif path.suffix == ".swift":
            result.append(path)
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="+", type=Path)
    parser.add_argument("--check", action="store_true", help="report files that would change")
    arguments = parser.parse_args()

    changed: list[Path] = []
    try:
        for path in swift_files(arguments.paths):
            original = path.read_text(encoding="utf-8").splitlines(keepends=True)
            transformed = transform_lines(original, path)
            if transformed == original:
                continue
            changed.append(path)
            if not arguments.check:
                path.write_text("".join(transformed), encoding="utf-8")
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2

    for path in changed:
        print(path)
    return 1 if arguments.check and changed else 0


if __name__ == "__main__":
    raise SystemExit(main())
