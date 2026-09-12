#!/usr/bin/env python3
"""Check section and equation references in generated HTML and TeX."""

from __future__ import annotations

import argparse
from collections import Counter
from html.parser import HTMLParser
import json
from pathlib import Path
from urllib.parse import urljoin, urlsplit, unquote


EQUATION_LABELS = ("def-hlm", "eqdifflhil")
SECTION_LABEL = "sec-TT___-T___T"
SITE_URL = "https://blueprint.invalid/"


class Page(HTMLParser):
    def __init__(self, url: str) -> None:
        super().__init__()
        self.base = url
        self.ids: Counter[str] = Counter()
        self.links: list[tuple[str, str]] = []
        self.in_paragraph = False
        self.link: tuple[str, list[str]] | None = None

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attributes = dict(attrs)
        if identity := attributes.get("id"):
            self.ids[identity] += 1
        if tag == "base" and (href := attributes.get("href")):
            self.base = urljoin(self.base, href)
        if tag == "p":
            self.in_paragraph = True
        if tag == "a" and self.in_paragraph and (href := attributes.get("href")):
            self.link = (urljoin(self.base, href), [])

    def handle_data(self, data: str) -> None:
        if self.link is not None:
            self.link[1].append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag == "a" and self.link is not None:
            href, text = self.link
            self.links.append((href, "".join(text).strip()))
            self.link = None
        if tag == "p":
            self.in_paragraph = False


def check_site(site: Path, tex: Path | None) -> None:
    xrefs = json.loads((site / "xref.json").read_text())
    pages: dict[Path, Page] = {}
    for path in site.rglob("*.html"):
        page = Page(urljoin(SITE_URL, path.relative_to(site).as_posix()))
        page.feed(path.read_text())
        pages[path.resolve()] = page
    links = [link for page in pages.values() for link in page.links]

    targets = [
        (SECTION_LABEL, xrefs["Verso.Genre.Manual.section"]["contents"].get(SECTION_LABEL, [])),
        *((label, xrefs.get("CarlesonBlueprint.equation", {}).get("contents", {}).get(label, []))
          for label in EQUATION_LABELS),
    ]
    nodes = xrefs["«Informal.Block.informal»"]["contents"]
    assert not any(label in nodes for label in (*EQUATION_LABELS, SECTION_LABEL)), (
        "Document targets must not introduce Blueprint nodes"
    )
    latex = tex.read_text() if tex else None
    for label, entries in targets:
        if len(entries) != 1:
            raise AssertionError(f"{label}: expected one canonical target, got {len(entries)}")
        entry = entries[0]
        target = urljoin(SITE_URL, entry["address"]) + "#" + entry["id"]
        address = urlsplit(target)
        path = site / unquote(address.path).lstrip("/")
        if path.is_dir():
            path /= "index.html"
        if path.resolve() not in pages or pages[path.resolve()].ids[unquote(address.fragment)] != 1:
            raise AssertionError(f"{label}: expected one HTML target: {target}")
        if not any(unquote(href) == unquote(target) and text for href, text in links):
            raise AssertionError(f"{label}: no nonempty prose link reaches its canonical target")

        if latex is not None and label in EQUATION_LABELS:
            # Verso doubles hyphens when encoding these ASCII slugs for TeX.
            tex_label = entry["id"].replace("-", "--")
            assert latex.count("\\label{" + tex_label + "}") == 1, label
            assert "\\hyperref[" + tex_label + "]" in latex, label


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--site-dir", type=Path, default=Path("_out/site/html-multi"))
    parser.add_argument("--tex", type=Path, help="Also check equation targets in this generated TeX file")
    args = parser.parse_args()
    check_site(args.site_dir, args.tex)
    print("Section and equation reference regression passed.")


if __name__ == "__main__":
    main()
