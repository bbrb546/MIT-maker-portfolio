"""
algorithm2.py

All long-rest-specific processing: reading the "how many measures" number
printed on/near each detected "long rest" (digits on top) or "long rest
bottom" (digits on bottom) glyph, and turning that reading into a
measure-duration for algorithm1's measure counter.

The digits are read by cutting each glyph's detected bounding box out of
the page and running it
through EasyOCR (restricted to the characters 0-9). EasyOCR returns text
fragments with bounding boxes; those fragments are sorted left-to-right
and concatenated into the final number.
"""

import cv2

_reader = None


def _get_reader():
    """Create the EasyOCR reader on first use and reuse it afterwards."""
    global _reader
    if _reader is None:
        import easyocr

        try:
            import torch
            use_gpu = torch.cuda.is_available()
        except ImportError:
            use_gpu = False

        _reader = easyocr.Reader(["en"], gpu=use_gpu, verbose=False)
    return _reader


def crop_box(image, pred):
    """Cut a prediction's exact bounding box out of `image`. No padding,
    no top/bottom half selection and no left/right trimming: the OCR
    sees the whole glyph box."""
    h_img, w_img = image.shape[:2]
    x, y, w, h = pred["x"], pred["y"], pred["width"], pred["height"]

    x1 = int(max(0, x - w / 2))
    y1 = int(max(0, y - h / 2))
    x2 = int(min(w_img, x + w / 2))
    y2 = int(min(h_img, y + h / 2))

    cv2.imwrite("lout/long_rest{}.png".format(pred["detection_id"]), image[y1:y2, x1:x2])
    return image[y1:y2, x1:x2]


def preprocess_for_ocr(crop, scale=4, border=20):
    """Prepare a small crop for EasyOCR: convert to grayscale, upscale so
    the digits are comfortably large, and add a white border so digits
    touching the crop edge aren't clipped by the text detector."""
    if crop.ndim == 3:
        crop = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
    crop = cv2.resize(crop, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)
    return cv2.copyMakeBorder(crop, border, border, border, border,
                              cv2.BORDER_CONSTANT, value=255)


def digits_from_ocr_results(ocr_results, conf_threshold=0.3):
    """Combine EasyOCR results into the multi-digit number they represent.

    `ocr_results` is EasyOCR's readtext(detail=1) output: a list of
    (bbox, text, confidence) tuples, where bbox is four (x, y) corner
    points. Keep only confident-enough fragments that contain digits, sort
    them left-to-right by the bbox's left edge, and concatenate their text.

    Returns (digit_string, mean_confidence), or (None, 0.0) if nothing
    usable came back.
    """
    usable = []
    for bbox, text, conf in ocr_results:
        digits = "".join(ch for ch in text if ch.isdigit())
        if digits and conf >= conf_threshold:
            left_x = min(pt[0] for pt in bbox)
            usable.append((left_x, digits, conf))

    if not usable:
        return None, 0.0

    usable.sort(key=lambda t: t[0])
    digits = "".join(t[1] for t in usable)

    if not digits.isdigit() or len(digits) > 3:
        return None, 0.0

    mean_conf = sum(t[2] for t in usable) / len(usable)
    return digits, mean_conf


def read_number(crop):
    """Run EasyOCR on a crop and return the resulting
    (digit_string, confidence), or (None, 0.0) if nothing usable was
    found."""
    if crop.size == 0:
        return None, 0.0

    processed = preprocess_for_ocr(crop)
    results = _get_reader().readtext(
        processed,
        allowlist="0123456789",
        detail=1,
        paragraph=False,
    )
    return digits_from_ocr_results(results)


def ocr_annotate_long_rests(preds, image_path, api_key=None):
    """Mutate every "long rest" / "long rest bottom" prediction in `preds`
    IN PLACE, adding "measure_count" (digit string or None) and
    "measure_count_confidence".

    `api_key` is no longer used (digits are now read locally with EasyOCR
    rather than via a Roboflow workflow); it is kept as an optional
    parameter so existing callers don't need to change.

    Operating in place keeps these dicts as the same objects that
    algorithm1's line-grouping will later sort into lines, so the digit
    reading travels with each detection automatically -- no re-matching
    by detection_id needed."""
    image = cv2.imread(image_path)
    if image is None:
        raise FileNotFoundError(f"Could not read image: {image_path}")

    for pred in preds:
        if pred["class"] not in ("long rest", "long rest bottom"):
            continue
        crop = crop_box(image, pred)
        digits, conf = read_number(crop)
        pred["measure_count"] = digits
        pred["measure_count_confidence"] = conf

    return preds


def duration_is_confident(pred):
    return 1


def duration_from_ocr(pred, default=-1):
    """rest_duration_fn for algorithm1.annotate_measure_numbers() /
    to_label_strings(). Reads the OCR result stashed by
    ocr_annotate_long_rests(), falling back to `default` if nothing
    confident came back -- this keeps a single bad reading from crashing
    the whole measure count, at the cost of that rest's count possibly
    being wrong."""
    digits = pred.get("measure_count")
    if not digits:
        return default
    return int(digits)