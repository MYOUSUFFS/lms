"""
LMS RAG Backend - CSV Document Processor
Uses pandas for CSV/Excel processing
"""

from pathlib import Path
from typing import Optional

import pandas as pd

from app.services.processors.base import (
    BaseDocumentProcessor,
    ProcessedChunk,
    ProcessedDocument,
)


class CSVProcessor(BaseDocumentProcessor):
    """CSV and Excel document processor using pandas."""
    
    SUPPORTED_EXTENSIONS = ["csv", "xlsx", "xls"]
    
    def supports(self, file_extension: str) -> bool:
        """Check if this processor supports CSV/Excel files."""
        return file_extension.lower() in self.SUPPORTED_EXTENSIONS
    
    def process(self, file_path: Path, document_id: str) -> ProcessedDocument:
        """
        Process a CSV or Excel document.
        
        Args:
            file_path: Path to the CSV/Excel file
            document_id: Unique identifier for the document
            
        Returns:
            ProcessedDocument with extracted content
        """
        self.logger.info(f"Processing CSV/Excel: {file_path.name}")
        
        try:
            extension = file_path.suffix.lower().lstrip(".")
            
            if extension == "csv":
                df = self._read_csv(file_path)
            else:
                df = self._read_excel(file_path)
            
            # Convert dataframe to text representation
            content = self._dataframe_to_text(df)
            
            # Create chunk
            chunk = ProcessedChunk(
                content=content,
                metadata={
                    "rows": len(df),
                    "columns": len(df.columns),
                    "column_names": list(df.columns),
                },
                chunk_index=0,
            )
            
            metadata = self._create_base_metadata(file_path, document_id)
            metadata.update({
                "rows": len(df),
                "columns": len(df.columns),
                "column_names": list(df.columns),
                "processor": "csv_pandas",
            })
            
            self.logger.info(f"CSV processed: {len(df)} rows, {len(df.columns)} columns")
            
            return ProcessedDocument(
                document_id=document_id,
                filename=file_path.name,
                content=content,
                chunks=[chunk],
                metadata=metadata,
            )
            
        except Exception as e:
            self.logger.error(f"Error processing CSV/Excel {file_path.name}: {e}")
            raise
    
    def _read_csv(self, file_path: Path) -> pd.DataFrame:
        """
        Read CSV file with encoding detection.
        
        Args:
            file_path: Path to CSV file
            
        Returns:
            pandas DataFrame
        """
        encodings = ["utf-8", "latin-1", "cp1252"]
        
        for encoding in encodings:
            try:
                return pd.read_csv(file_path, encoding=encoding)
            except UnicodeDecodeError:
                continue
        
        # Fallback
        return pd.read_csv(file_path, encoding="utf-8", errors="replace")
    
    def _read_excel(self, file_path: Path) -> pd.DataFrame:
        """
        Read Excel file.
        
        Args:
            file_path: Path to Excel file
            
        Returns:
            pandas DataFrame (first sheet)
        """
        return pd.read_excel(file_path, sheet_name=0)
    
    def _dataframe_to_text(self, df: pd.DataFrame, max_rows: int = 1000) -> str:
        """
        Convert DataFrame to readable text format.
        
        Args:
            df: pandas DataFrame
            max_rows: Maximum rows to include
            
        Returns:
            Text representation of the data
        """
        # Limit rows for very large files
        if len(df) > max_rows:
            df = df.head(max_rows)
            truncated = True
        else:
            truncated = False
        
        lines = []
        
        # Add header
        lines.append("Columns: " + ", ".join(df.columns))
        lines.append("")
        
        # Add data as readable rows
        for idx, row in df.iterrows():
            row_text = " | ".join([f"{col}: {val}" for col, val in row.items()])
            lines.append(f"Row {idx + 1}: {row_text}")
        
        if truncated:
            lines.append(f"\n[Truncated: showing first {max_rows} of {len(df)} rows]")
        
        return "\n".join(lines)
