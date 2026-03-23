#! /usr/bin/python3
# -*- coding: utf-8 -*-

import logging
import pathlib
import zipfile
import argparse
import configparser

from io import BytesIO

from lxml import etree


__version__ = "0.2.0"


class Transformer:
    """ALTO to TEI transformer."""

    ALTO_NS = "http://www.loc.gov/standards/alto/ns-v4#"
    TEI_NS = "http://www.tei-c.org/ns/1.0"

    def __init__(self, args, config):
        self.logger = logging.getLogger(self.__class__.__name__)
        self.args = args
        self.config = config

    def _make_xml_id(self, value):
        """Build a safe xml:id from a string."""
        allowed = set(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.-"
        )
        cleaned = []

        for char in value:
            if char in allowed:
                cleaned.append(char)
            else:
                cleaned.append("_")

        result = "".join(cleaned) or "page"

        if not (result[0].isalpha() or result[0] == "_"):
            result = f"P_{result}"

        return result

    def _transform_xslt(self, content, xslt, replace_ns=False, **kwargs):
        """Transform content using XSLT."""
        parser = etree.XMLParser(remove_blank_text=True)

        try:
            tree = etree.parse(BytesIO(content), parser)

            if replace_ns:
                nsmap = tree.getroot().nsmap
                if None in nsmap and nsmap[None] != self.ALTO_NS:
                    old_ns = nsmap[None]
                    self.logger.warning(
                        f"replace deprecated namespace '{old_ns}' by '{self.ALTO_NS}'"
                    )
                    with open(self.config["xsl"]["ns"], "rb") as fp:
                        replacer = etree.XSLT(etree.parse(fp, parser))
                        tree = replacer(
                            tree,
                            old_ns=etree.XSLT.strparam(old_ns),
                            new_ns=etree.XSLT.strparam(self.ALTO_NS),
                        )

            with open(xslt, "rb") as fp:
                transformer = etree.XSLT(etree.parse(fp, parser))
                result = transformer(tree, **kwargs)
                return etree.tostring(
                    result,
                    encoding="utf-8",
                    pretty_print=True,
                    xml_declaration=True,
                )

        except Exception as exception:
            self.logger.exception(exception)
            raise SystemExit(1)

    def _build_output_tree(self):
        tei_root = etree.Element(
            "{%s}TEI" % self.TEI_NS,
            nsmap={None: self.TEI_NS}
        )
        tei_root.set("{http://www.w3.org/XML/1998/namespace}lang", "fr")

        tei_header = etree.SubElement(tei_root, "{%s}teiHeader" % self.TEI_NS)
        file_desc = etree.SubElement(tei_header, "{%s}fileDesc" % self.TEI_NS)

        title_stmt = etree.SubElement(file_desc, "{%s}titleStmt" % self.TEI_NS)
        title = etree.SubElement(title_stmt, "{%s}title" % self.TEI_NS)
        title.text = f"Conversion ALTO → TEI de {self.args.input_dir.name}"

        publication_stmt = etree.SubElement(
            file_desc, "{%s}publicationStmt" % self.TEI_NS
        )
        publisher = etree.SubElement(
            publication_stmt, "{%s}publisher" % self.TEI_NS
        )
        publisher.text = ""

        source_desc = etree.SubElement(file_desc, "{%s}sourceDesc" % self.TEI_NS)
        p_source = etree.SubElement(source_desc, "{%s}p" % self.TEI_NS)
        p_source.text = self.args.input_dir.name

        text = etree.SubElement(tei_root, "{%s}text" % self.TEI_NS)
        body = etree.SubElement(text, "{%s}body" % self.TEI_NS)

        return tei_root, body

    def transform(self):
        filenames = sorted(
            self.args.input_dir.iterdir(),
            key=lambda x: str(x)
        )
        filenames = [f for f in filenames if f.suffix in (".xml", ".XML")]

        if not filenames:
            self.logger.info("No ALTO files")
            return

        tei_root, body = self._build_output_tree()
        parser = etree.XMLParser(remove_blank_text=True)

        for filename in filenames:
            self.logger.debug(f"read {filename}")
            with filename.open("rb") as fp:
                content = fp.read()

            page_id = self._make_xml_id(filename.stem)

            transformed = self._transform_xslt(
                content,
                self.config["xsl"]["tei"],
                replace_ns=True,
                page_id=etree.XSLT.strparam(page_id),
                source_name=etree.XSLT.strparam(filename.name),
            )

            page_tree = etree.parse(BytesIO(transformed), parser)
            page_root = page_tree.getroot()

            page_body = page_root.find(".//{%s}body" % self.TEI_NS)
            if page_body is not None:
                for child in page_body:
                    body.append(child)

        output = etree.tostring(
            tei_root,
            pretty_print=True,
            encoding="utf-8",
            xml_declaration=True,
        )

        with open(self.args.output_filename, "wb") as fp:
            fp.write(output)


def _init_config():
    parent = pathlib.Path(__file__).parent.resolve()
    xsl = parent / "xsl"
    config = configparser.ConfigParser()
    config.read_dict(
        {
            "xsl": {
                "tei": str(xsl / "alto2tei.xsl"),
                "ns": str(xsl / "replacens.xsl"),
            }
        }
    )
    return config


def _input_dir(dir_):
    if zipfile.is_zipfile(dir_):
        return zipfile.Path(dir_)
    dir_ = pathlib.Path(dir_)
    if not dir_.is_dir():
        raise FileNotFoundError(f"No such directory: {dir_}")
    return dir_


def _init_argument_parser():
    parser = argparse.ArgumentParser(
        prog="alto2tei",
        description="Command line program to convert ALTO files to XML/TEI.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "input_dir",
        type=_input_dir,
        help="input directory",
    )
    parser.add_argument(
        "--version",
        action="version",
        version=f"%(prog)s {__version__}",
        help="print %(prog)s version",
    )
    parser.add_argument(
        "--level",
        default="INFO",
        choices=("INFO", "DEBUG"),
        help="set logging level",
    )
    parser.add_argument(
        "-o",
        "--output-filename",
        default="<input directory>.xml",
        help="output filename",
    )
    return parser


def main():
    parser = _init_argument_parser()
    args = parser.parse_args()

    if args.output_filename == parser.get_default("output_filename"):
        args.output_filename = f"{args.input_dir.stem}.xml"

    logging.basicConfig(
        format="[%(asctime)s] %(levelname)s %(name)s: %(message)s",
        level=logging.getLevelName(args.level),
    )

    logger = logging.getLogger("main")
    logger.info(f"transform {args.input_dir} into {args.output_filename}")

    transformer = Transformer(args, _init_config())
    transformer.transform()


if __name__ == "__main__":
    main()