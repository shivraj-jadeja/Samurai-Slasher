"""Verify recovered assets against retained compiled texture/audio data.

Run from any folder: python path/to/validation/verify_pack.py
Requires Pillow (PIL); uses only local files and never launches the executable.
This verifies recovery consistency, not GameMaker project or runtime behavior.
"""
from pathlib import Path
import hashlib
import io
import json
import struct
import wave
import zipfile

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent


def read_json(name):
    return json.loads((ROOT / "metadata" / name).read_text(encoding="utf-8"))


def require(condition, message):
    if not condition:
        raise ValueError(message)


def verify():
    manifest = read_json("asset_manifest.json")
    sprites = read_json("sprites.json")
    named = {s["Name"]: s for s in sprites if s is not None}
    items = {t["Name"]: t for t in read_json("texture_items.json")}
    pages = {}
    for path in (ROOT / "reference" / "EmbeddedTextures").glob("*.png"):
        with Image.open(path) as image:
            pages[path.stem] = image.convert("RGBA")
    require(len(named) == len(manifest) == 39, "Named sprite count mismatch")
    require(len(pages) == 2, "Expected two texture pages")
    frame_count = 0
    for entry in manifest:
        name = entry["resource"]
        sprite = named[name]
        width, height = entry["width"], entry["height"]
        require(len(sprite["Textures"]) == entry["frames"], f"Frame count: {name}")
        with Image.open(ROOT / entry["strip"]) as raw_strip:
            strip = raw_strip.convert("RGBA")
        require(strip.size == (width * entry["frames"], height), f"Strip size: {name}")
        paths = sorted((ROOT / entry["frames_directory"]).glob("*.png"))
        require(len(paths) == entry["frames"], f"Frame directory count: {name}")
        for index, texture in enumerate(sprite["Textures"]):
            path = ROOT / entry["frames_directory"] / f"{index:03}.png"
            with Image.open(path) as raw_frame:
                frame = raw_frame.convert("RGBA")
            require(frame.size == (width, height), f"Canvas: {path.name}")
            part = strip.crop((index * width, 0, (index + 1) * width, height))
            require(frame.tobytes() == part.tobytes(), f"Strip pixels: {name}/{index}")
            item = items[texture["Texture"]]
            page = pages[item["TexturePage"]]
            sx, sy = item["SourceX"], item["SourceY"]
            sw, sh = item["SourceWidth"], item["SourceHeight"]
            require(sw == item["TargetWidth"] and sh == item["TargetHeight"],
                    f"Unexpected atlas rescaling: {name}/{index}")
            region = page.crop((sx, sy, sx + sw, sy + sh))
            expected = Image.new("RGBA", (width, height))
            expected.paste(region, (item["TargetX"], item["TargetY"]))
            require(frame.tobytes() == expected.tobytes(), f"Atlas pixels: {name}/{index}")
            frame_count += 1
    require(frame_count == 132, "Expected 132 total frames")

    archive = ROOT / "original_build" / "Jadeja_Shivraj_Assn3.zip"
    with zipfile.ZipFile(archive) as original:
        require(original.testzip() is None, "Original archive CRC failed")
        data = original.read("data.win")
        source_files = {name: {"bytes": len(original.read(name)),
                              "sha256": hashlib.sha256(original.read(name)).hexdigest()}
                        for name in original.namelist()}
    require(data[:4] == b"FORM", "Expected a compiled GameMaker FORM file")
    chunks = {}
    pos = 8
    while pos < len(data):
        tag = data[pos:pos + 4].decode("ascii")
        length = struct.unpack_from("<I", data, pos + 4)[0]
        chunks[tag] = (pos + 8, length)
        pos += 8 + length
    require(pos == len(data), "Compiled chunk boundaries mismatch")
    audio_pos, _ = chunks["AUDO"]
    count = struct.unpack_from("<I", data, audio_pos)[0]
    pointers = struct.unpack_from(f"<{count}I", data, audio_pos + 4)
    sounds = read_json("sounds.json")
    require(count == len(sounds) == 3, "Expected all three embedded sounds")
    audio_report = []
    for sound in sounds:
        offset = pointers[sound["AudioID"]]
        length = struct.unpack_from("<I", data, offset)[0]
        embedded = data[offset + 4:offset + 4 + length]
        exported = (ROOT / "assets" / "audio" / (sound["Name"] + ".wav")).read_bytes()
        require(embedded == exported, f"Audio bytes differ: {sound['Name']}")
        with wave.open(io.BytesIO(exported), "rb") as audio:
            require(audio.getnframes() > 0, "Empty sound")
            audio_report.append({"name": sound["Name"], "channels": audio.getnchannels(),
                                 "sample_rate": audio.getframerate(),
                                 "sample_width_bytes": audio.getsampwidth(),
                                 "duration_seconds": audio.getnframes() / audio.getframerate(),
                                 "sha256": hashlib.sha256(exported).hexdigest()})

    objects = read_json("objects.json")
    for obj in objects:
        for events in obj["Events"]:
            for event in events:
                for action in event["Actions"]:
                    code = action.get("CodeId")
                    if code:
                        require((ROOT / "reference" / "CodeEntries" / (code + ".gml")).is_file(),
                                f"Missing event code: {code}")
    source_hashes = {"archive_sha256": hashlib.sha256(archive.read_bytes()).hexdigest(),
                     "files": source_files}
    (ROOT / "validation" / "source_hashes.json").write_text(
        json.dumps(source_hashes, indent=2) + "\n", encoding="utf-8")
    report = {
        "extraction_checks": "PASS", "named_sprites": len(named),
        "compiled_sprite_slots": len(sprites), "null_sprite_slots": 4,
        "frames_verified_against_atlas_pixels": frame_count,
        "strips_verified_against_frames": len(manifest), "texture_pages": len(pages),
        "audio_files_verified_byte_for_byte_against_data_win": len(audio_report),
        "audio": audio_report,
        "object_definitions": len(objects), "rooms": len(read_json("rooms.json")),
        "top_level_decompiled_files": len(list((ROOT / "reference" / "CodeEntries").glob("*.gml"))),
        "compiled_code_entries": len(read_json("asset_order.json")["code"]),
        "original_archive_crc": "PASS", "event_code_references": "PASS",
        "windows_executable_playtest": "NOT RUN",
        "gamemaker_remake_compile": "NOT RUN - handoff package, not an implemented project",
    }
    (ROOT / "validation" / "extraction_report.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    verify()
