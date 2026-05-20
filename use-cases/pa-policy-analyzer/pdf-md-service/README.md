# PDF-to-Markdown Service

Lightweight PDF-to-Markdown conversion service for the PA Policy Analyzer prior authorization demo. Built with [FastAPI](https://fastapi.tiangolo.com/) and [PyMuPDF4LLM](https://github.com/pymupdf/RAG).

Converts payer policy PDFs into clean Markdown so the BFF can feed them to Claude for structured extraction of coverage clauses and billing codes.

## What it does

1. **File-based conversion** -- Takes a filename reference to a PDF already stored on disk (in the BFF's `data/pdfs/` directory), converts it to Markdown, and writes the result to `data/mds/`.

2. **Upload-based conversion** -- Accepts a PDF file upload, converts it to Markdown in a temporary file, and returns the result without persisting anything.

Both endpoints use PyMuPDF4LLM under the hood, which produces LLM-friendly Markdown with good table and layout preservation.

## Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) (recommended) or pip

## Setup

### 1. Install dependencies

```bash
uv sync
```

Or with pip:

```bash
pip install -e .
```

### 2. Run

```bash
uv run main.py
```

The service starts on **port 6093** and serves all endpoints under `/v1`.

## API overview

| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/convertPDF` | Convert a PDF already on disk (body: `{filename}`) |
| POST | `/v1/convert` | Convert an uploaded PDF file (multipart form: `file`) |

### POST `/v1/convertPDF`

Converts a PDF from the BFF's `data/pdfs/` directory and writes the Markdown output to `data/mds/`.

**Request body:**

```json
{
  "filename": "policy-document.pdf"
}
```

**Response:**

```json
{
  "markdown_path": "../bff/data/mds/policy-document.md",
  "markdown": "# Policy Document\n\n..."
}
```

### POST `/v1/convert`

Converts an uploaded PDF to Markdown without persisting either file.

**Request:** multipart/form-data with a `file` field containing the PDF.

**Response:**

```json
{
  "markdown": "# Policy Document\n\n..."
}
```

## Project structure

```
pdf-md-service/
  main.py              FastAPI application with conversion endpoints
  pyproject.toml       Project metadata and dependencies
  .python-version      Python version pin (3.13)
```
