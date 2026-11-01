"""
algorithm1_proximity.py

All detection post-processing EXCEPT long-rest duration reading:

  - group_into_lines: groups purely by y-proximity. Detections are sorted
    by center-y and a detection joins the current line if its center-y is
    within `y_tolerance` pixels (default 10) of that line's mean center-y;
    otherwise it starts a new line. No RANSAC, no randomness, no
    dependence on box height.
  - merge_close_lines: kept only so existing callers (main.py) still work.
    It is now a pass-through, because the proximity rule already defines
    exactly what belongs together.
"""

import math

import cv2


LONG_REST_CLASSES = ('long rest', 'long rest bottom')

Y_TOLERANCE = 30  # max distance (px) between a detection's center-y and its line's mean center-y


def group_into_lines(preds, y_tolerance=Y_TOLERANCE):
    """Group detections into staff lines using only the proximity of their
    center y-values.

    Detections are processed top-to-bottom. Each one is compared with the
    running mean center-y of the line currently being built: if it is
    within `y_tolerance` pixels it joins that line, otherwise it starts a
    new one. Comparing against the running mean (rather than only the
    previous detection) stops a gradual drift from chaining distant
    detections into one line.

    Returns a list of lines, each a list of pred dicts sorted
    left-to-right, with the lines themselves ordered top-to-bottom.
    """
    if not preds:
        return []

    ordered = sorted(preds, key=lambda p: p["y"])

    lines = []
    current = [ordered[0]]
    current_sum = ordered[0]["y"]

    for p in ordered[1:]:
        mean_y = current_sum / len(current)
        if abs(p["y"] - mean_y) <= y_tolerance:
            current.append(p)
            current_sum += p["y"]
        else:
            lines.append(current)
            current = [p]
            current_sum = p["y"]
    lines.append(current)

    return [sorted(line, key=lambda p: p["x"]) for line in lines]


def merge_close_lines(lines, merge_frac=0.5):
    """Pass-through, kept for API compatibility with algorithm1.

    The original merged over-segmented lines using a spacing heuristic.
    With pure y-proximity grouping there is nothing to repair: two
    detections are on the same line exactly when their y-values are within
    the tolerance. `merge_frac` is ignored."""
    return lines


def remove_doubled_long_rests(lines):
    """Merge consecutive same-type long-rest detections within each staff
    line when no bar separates them.

    A very wide rest can occasionally be detected as two boxes.  Because
    lines are ordered left-to-right, consecutive matching long-rest classes
    represent such a split unless a bar-like detection occurs between them.
    The replacement box is the union of the two boxes, allowing downstream
    OCR to read the duration from the complete glyph.
    """
    long_rest_classes = ("long rest", "long rest bottom")
    bar_classes = ("bar", "repeat bar", "double bar")

    for line in lines:
        merged_line = []
        for pred in line:
            if (
                merged_line
                and pred["class"] in long_rest_classes
                and merged_line[-1]["class"] == pred["class"]
                and merged_line[-1]["class"] not in bar_classes
            ):
                previous = merged_line[-1]
                x1 = min(previous["x"] - previous["width"] / 2,
                         pred["x"] - pred["width"] / 2)
                y1 = min(previous["y"] - previous["height"] / 2,
                         pred["y"] - pred["height"] / 2)
                x2 = max(previous["x"] + previous["width"] / 2,
                         pred["x"] + pred["width"] / 2)
                y2 = max(previous["y"] + previous["height"] / 2,
                         pred["y"] + pred["height"] / 2)
                previous["x"] = (x1 + x2) / 2
                previous["y"] = (y1 + y2) / 2
                previous["width"] = x2 - x1
                previous["height"] = y2 - y1
            else:
                merged_line.append(pred)
        line[:] = merged_line

    return lines


def insert_endings(lines, ending_preds):
    """Assign each "ending" detection to the line containing the closest
    detection that lies below it, then insert it into that line in
    left-to-right order.

    "ending" boxes sit above their staff line and are unusually wide/short,
    which makes them poor anchors for line-fitting -- they're excluded from
    group_into_lines and reattached here instead."""
    id_to_line = {}
    for i, line in enumerate(lines):
        for p in line:
            id_to_line[id(p)] = i

    for ending in ending_preds:
        ex, ey = ending["x"], ending["y"]

        candidates = [p for line in lines for p in line if p["y"] > ey]
        if not candidates:
            # fallback: nothing below it anywhere (e.g. ending on the very
            # last line) -- use the closest detection overall
            candidates = [p for line in lines for p in line]
        if not candidates:
            continue  # no other detections at all; nothing to attach to

        closest = min(candidates, key=lambda p: math.hypot(p["x"] - ex, p["y"] - ey))
        target_idx = id_to_line[id(closest)]

        lines[target_idx].append(ending)
        lines[target_idx].sort(key=lambda p: p["x"])
        id_to_line[id(ending)] = target_idx

    return lines


def annotate_measure_numbers(lines, rest_duration_fn, initial_measure_number=1):
    """Walk the line-grouped detections in reading order, tagging each with
    its measure number.

    Convention:
      - "bar" / "repeat bar" / "double bar" mark the END of a measure, so
        the running counter increments by 1 right after one is seen.
      - "long rest" / "long rest bottom" represent a multi-measure rest: it
        is stamped with the measure number it STARTS at, and the counter
        jumps forward by rest_duration_fn(pred) instead of by 1.
      - anything else is tagged with the current measure number but does
        not advance the counter.

    `initial_measure_number` is the number given to the page's first bar, or
    the number a leading long rest starts at. The caller chooses it; the
    Chronocounter app sends a provisional value and renumbers locally (see
    its SPEC section 4).

    Returns the same array-of-arrays shape, with each pred dict replaced by
    {"class": ..., "measure_number": ..., "detection": pred_dict}.
    """
    measure_num = initial_measure_number
    first_counted_detection = True
    annotated = []
    pcls = "fpbar"  # pretend a "fake previous bar" was seen before the first line
    for line in lines:
        line_out = []
        for p in line:
            cls = p["class"]
            entry = {"class": cls, "measure_number": measure_num, "detection": p}
            if cls in ("long rest", "long rest bottom"):
                first_counted_detection = False
                n = rest_duration_fn(p)
                entry["measures_spanned"] = n
                measure_num += n
            elif cls in ("bar", "repeat bar", "double bar"):
                if not first_counted_detection and pcls in (
                    "bar", "repeat bar", "double bar", "pbar", "fpbar"
                ):
                    measure_num += 1
                entry["measure_number"] = measure_num
                first_counted_detection = False

            line_out.append(entry)

            pcls = cls

        pcls = "pbar"
        annotated.append(line_out)
    return annotated


def to_label_strings(lines, rest_duration_fn):
    """Simplified string-based view: same array-of-arrays shape, each
    element replaced by its class name, with long rests tagged as
    "long rest:<n_measures>"."""
    output = []
    for line in lines:
        line_out = []
        for p in line:
            if p["class"] in ("long rest", "long rest bottom"):
                n = rest_duration_fn(p)
                line_out.append(f"{p['class']}:{n}")
            else:
                line_out.append(p["class"])
        output.append(line_out)
    return output


def end_measure(entry):
    """Measure number in force immediately AFTER this detection.
    A long rest is stamped with the measure it STARTS at, so add the
    measures it spans; anything else already carries the right number."""
    n = entry.get('measures_spanned')
    if entry['class'] in LONG_REST_CLASSES and n:
        return entry['measure_number'] + n
    return entry['measure_number']


def draw_measure_numbers(image, annotated_lines, font=cv2.FONT_HERSHEY_SIMPLEX,
                          font_scale=0.8, color=(0, 0, 0), thickness=2, gap=15):
    """Draw each line's starting measure number near the image's left
    edge, vertically aligned with that line. On the first line the
    number is the first detection's number minus 1, unless that
    detection is a long rest (then its own number). On every later
    line it is end_measure() of the rightmost detection of the
    preceding line (start + span if that detection is a long rest).
    Mutates `image` in place and also returns it."""
    previous_end_measure_num = None
    for line in annotated_lines:
        if not line:
            continue

        detections = [entry["detection"] for entry in line]
        text_y = int(sum(d["y"] for d in detections) / len(detections))
        first = line[0]
        if previous_end_measure_num is not None:
            measure_num = previous_end_measure_num
        elif first['class'] in LONG_REST_CLASSES:
            measure_num = first['measure_number']
        else:
            measure_num = first['measure_number'] - 1

        text = str(measure_num)
        (_, text_h), _ = cv2.getTextSize(text, font, font_scale, thickness)
        text_x = gap

        cv2.putText(image, text, (text_x, text_y + text_h // 2),
                    font, font_scale, color, thickness, cv2.LINE_AA)

        previous_end_measure_num = end_measure(
            max(line, key=lambda entry: entry["detection"]["x"])
        )

    return image