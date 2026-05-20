import pathlib
import tempfile
import uvicorn
import pymupdf4llm
from pydantic import BaseModel
from fastapi import FastAPI, HTTPException, File, UploadFile

app = FastAPI()

PDF_DIR = pathlib.Path("../bff/data/pdfs")
MD_DIR = pathlib.Path("../bff/data/mds")


class ConvertRequest(BaseModel):
    filename: str


class ConvertResponse(BaseModel):
    markdown_path: str
    markdown: str


@app.post("/v1/convertPDF", response_model=ConvertResponse)
def convert_pdf(req: ConvertRequest) -> ConvertResponse:
    pdf_path = PDF_DIR / req.filename
    if not pdf_path.exists():
        raise HTTPException(status_code=404, detail=f"File not found: {pdf_path}")

    md_text: str = pymupdf4llm.to_markdown(str(pdf_path))

    MD_DIR.mkdir(parents=True, exist_ok=True)
    md_filename = pdf_path.stem + ".md"
    md_path = MD_DIR / md_filename
    md_path.write_text(md_text, encoding="utf-8")

    return ConvertResponse(markdown_path=str(md_path), markdown=md_text)

@app.post("/v1/convert")
def convert_pdf_to_md(file: UploadFile = File(...)) -> dict:
    try:
        file_bytes = file.file.read()
        if not file_bytes:
            raise HTTPException(status_code=400, detail="Uploaded file is empty")

        with tempfile.NamedTemporaryFile(suffix=".pdf", delete=True) as temp_pdf:
            temp_pdf.write(file_bytes)
            temp_pdf.flush()
            md_text: str = pymupdf4llm.to_markdown(temp_pdf.name)

        return {"markdown": md_text}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Conversion failed: {str(e)}")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=6093)
