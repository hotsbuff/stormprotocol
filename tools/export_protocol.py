#!/usr/bin/env python3
import argparse
import ast
import json
import re
import urllib.request
from pathlib import Path

KINDS = {
    "_array": "array",
    "_bitarray": "bitarray",
    "_blob": "blob",
    "_bool": "bool",
    "_choice": "choice",
    "_fourcc": "fourcc",
    "_int": "int",
    "_null": "null",
    "_optional": "optional",
    "_real32": "real32",
    "_real64": "real64",
    "_struct": "struct",
}


def read_source(source):
    if source.startswith(("https://", "http://")):
        with urllib.request.urlopen(source) as response:
            return response.read().decode("utf-8")
    return Path(source).read_text(encoding="utf-8")


def export_type(kind, arguments):
    result = {"kind": KINDS[kind]}
    if kind in {"_array", "_bitarray", "_blob", "_choice", "_int"}:
        offset, bits = arguments[0]
        result["bounds"] = {"offset": offset, "bits": bits}
    if kind == "_array":
        result["type"] = arguments[1]
    elif kind == "_optional":
        result["type"] = arguments[0]
    elif kind == "_struct":
        result["fields"] = [
            {"name": name, "type": type_id, "tag": tag}
            for name, type_id, tag in arguments[0]
        ]
    elif kind == "_choice":
        result["choices"] = {
            str(tag): {"name": name, "type": type_id, "tag": tag}
            for tag, (name, type_id) in arguments[1].items()
        }
    return result


def export_events(events):
    return {
        str(event_id): {"type": type_id, "name": name}
        for event_id, (type_id, name) in events.items()
    }


def export_schema(source):
    text = read_source(source)
    tree = ast.parse(text)
    assignments = {}
    for node in tree.body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1:
            target = node.targets[0]
            if isinstance(target, ast.Name):
                assignments[target.id] = node.value

    def value(name):
        return ast.literal_eval(assignments[name])

    build_match = re.search(r"protocol(\d+)\.py", source)
    if build_match is None:
        raise ValueError("source name must contain protocol<build>.py")

    return {
        "build": int(build_match.group(1)),
        "exact": True,
        "types": [export_type(kind, args) for kind, args in value("typeinfos")],
        "header_type": value("replay_header_typeid"),
        "details_type": value("game_details_typeid"),
        "init_data_type": value("replay_initdata_typeid"),
        "game_event_id_type": value("game_eventid_typeid"),
        "message_event_id_type": value("message_eventid_typeid"),
        "tracker_event_id_type": value("tracker_eventid_typeid"),
        "delta_type": value("svaruint32_typeid"),
        "user_id_type": value("replay_userid_typeid"),
        "game_events": export_events(value("game_event_types")),
        "message_events": export_events(value("message_event_types")),
        "tracker_events": export_events(value("tracker_event_types")),
    }


def to_yaml(value, indent=0):
    padding = " " * indent
    if isinstance(value, dict):
        if not value:
            return padding + "{}\n"
        result = ""
        for key, item in value.items():
            rendered_key = str(key) if re.fullmatch(r"-?\d+", str(key)) else json.dumps(key)
            if isinstance(item, (dict, list)) and item:
                result += padding + rendered_key + ":\n" + to_yaml(item, indent + 2)
            else:
                result += padding + rendered_key + ": " + to_yaml(item).lstrip()
        return result
    if isinstance(value, list):
        if not value:
            return padding + "[]\n"
        result = ""
        for item in value:
            if isinstance(item, (dict, list)) and item:
                nested = to_yaml(item, indent + 2)
                result += padding + "- " + nested[indent + 2:]
            else:
                result += padding + "- " + to_yaml(item).lstrip()
        return result
    return padding + json.dumps(value) + "\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("source", help="protocol<build>.py path or URL")
    parser.add_argument("output", help="destination YAML file")
    args = parser.parse_args()

    schema = export_schema(args.source)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(to_yaml(schema), encoding="utf-8")


if __name__ == "__main__":
    main()
