using System;
using System.Globalization;
using System.Reflection;


namespace Indra.SGD.XmlGenerator.Engines
{
    public class MsftExcelEngine
    {
        Type ExcelType;
        object ExcelApplication;
        public object oBook;

        public MsftExcelEngine()
        {

            //Gets the type of the Excel application using programe id
            ExcelType = Type.GetTypeFromProgID("Excel.Application");

            //Creating Excel application instance from the type
            ExcelApplication = Activator.CreateInstance(ExcelType);
        }

        public void Open(string strFileName, bool ReadOnly)
        {
            object fileName = strFileName;
            object readOnly = ReadOnly;
            object missing = System.Reflection.Missing.Value;
            object[] oParams = new object[1];

            //Getting the WoorkBook collection [work Sheet collection]
            object oDocs = ExcelApplication.GetType().InvokeMember("Workbooks",
            System.Reflection.BindingFlags.GetProperty,
            null,
            ExcelApplication,
            null, CultureInfo.InvariantCulture);
            oParams = new object[3];
            oParams[0] = fileName;
            oParams[1] = missing;
            oParams[2] = readOnly;

            //Open the first work sheet
            oBook = oDocs.GetType().InvokeMember("Open", System.Reflection.BindingFlags.InvokeMethod,
            null,
            oDocs,
            oParams, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
            DisplayAlerts(false);
        }

        public void DisplayAlerts(bool visible)
        {
            ExcelApplication.GetType().InvokeMember("DisplayAlerts", BindingFlags.SetProperty, null, ExcelApplication, new object[] { visible }, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void Close()
        {
            //Closing the work sheet
            oBook.GetType().InvokeMember("Close", System.Reflection.BindingFlags.InvokeMethod,
            null,
            oBook,
            null, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void CellsReplace(string range, string old_valor, string new_valor)
        {
            object sheet;
            object range_obj;
            //FormatString(range);

            sheet = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_obj = sheet.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheet, new object[] { range });

            object[] args = new object[2];
            args[0] = old_valor;
            args[1] = new_valor;

            range_obj.GetType().InvokeMember("Replace", BindingFlags.InvokeMethod, null, range_obj, args);
        }

        public void SaveAsPT(string NewFileName, int format, string passwordWrite, bool recomendReadOnly)
        {
            //format numbers
            //www.rondebruin.nl/mac/mac020.htm

            //51 = xlOpenXMLWorkbook (without macro's in 2007-2013, xlsx)
            //52 = xlOpenXMLWorkbookMacroEnabled (with or without macro's in 2007-2013, xlsm)
            //50 = xlExcel12 (Excel Binary Workbook in 2007-2013 with or without macro's, xlsb)
            //56 = xlExcel8 (97-2003 format in Excel 2007-2013, xls)
            object[] oParams = new object[5];
            oParams[0] = NewFileName;
            oParams[1] = format; //"Excel.XlFileFormat.xlExcel8"; 
            oParams[2] = null;
            oParams[3] = passwordWrite;
            oParams[4] = recomendReadOnly;
            oBook.GetType().InvokeMember("SaveAs", System.Reflection.BindingFlags.InvokeMethod,
            null,
            oBook,
            oParams, System.Globalization.CultureInfo.CreateSpecificCulture("pt-PT"));
        }

        public void Quit()
        {
            //Close the Excel application block
            ExcelApplication.GetType().InvokeMember("Quit", System.Reflection.BindingFlags.InvokeMethod,
            null,
            ExcelApplication,
            null, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
            System.Runtime.InteropServices.Marshal.ReleaseComObject(ExcelApplication);
        }

        public void Save()
        {
            oBook.GetType().InvokeMember("Save", System.Reflection.BindingFlags.InvokeMethod,
                null,
                oBook,
                null, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void SaveAs(string NewFileName, int format, string passwordWrite, bool recomendReadOnly)
        {
            //format numbers
            //www.rondebruin.nl/mac/mac020.htm

            //51 = xlOpenXMLWorkbook (without macro's in 2007-2013, xlsx)
            //52 = xlOpenXMLWorkbookMacroEnabled (with or without macro's in 2007-2013, xlsm)
            //50 = xlExcel12 (Excel Binary Workbook in 2007-2013 with or without macro's, xlsb)
            //56 = xlExcel8 (97-2003 format in Excel 2007-2013, xls)
            object[] oParams = new object[5];
            oParams[0] = NewFileName;
            oParams[1] = format; //"Excel.XlFileFormat.xlExcel8"; 
            oParams[2] = null;
            oParams[3] = passwordWrite;
            oParams[4] = recomendReadOnly;
            oBook.GetType().InvokeMember("SaveAs", System.Reflection.BindingFlags.InvokeMethod,
            null,
            oBook,
            oParams, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void Cells(string range, string valor)
        {
            object sheet;
            object range_obj;
            //FormatString(range);

            sheet = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_obj = sheet.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheet, new object[] { range });
            range_obj.GetType().InvokeMember("Value", BindingFlags.SetProperty, null, range_obj, new object[] { "'" + valor }, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void CellsV(string range, string valor)
        {
            object sheet;
            object range_obj;
            //FormatString(range);

            sheet = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_obj = sheet.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheet, new object[] { range });
            range_obj.GetType().InvokeMember("Value", BindingFlags.SetProperty, null, range_obj, new object[] { valor }, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void ChangeSheet(int SheetNumber)
        {
            object sheet;
            sheet = oBook.GetType().InvokeMember("WorkSheets", BindingFlags.GetProperty, null, oBook, new object[] { SheetNumber });
            sheet.GetType().InvokeMember("Select", BindingFlags.InvokeMethod, null, sheet, null, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void ChangeSheet(string SheetName)
        {
            object sheet;
            sheet = oBook.GetType().InvokeMember("WorkSheets", BindingFlags.GetProperty, null, oBook, new object[] { SheetName });
            sheet.GetType().InvokeMember("Select", BindingFlags.InvokeMethod, null, sheet, null, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void CellsInt(string range, int valor)
        {
            object sheet;
            object range_obj;
            //FormatString(range);

            sheet = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_obj = sheet.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheet, new object[] { range });
            range_obj.GetType().InvokeMember("Value", BindingFlags.SetProperty, null, range_obj, new object[] { valor }, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void CopyRange(string rangeBefore, string rangeAfter)
        {

            //msdn.microsoft.com/es-es/library/microsoft.office.tools.excel.namedrange.pastespecial.aspx
            object sheet;
            object sheetto;
            object range_obj;
            object range_to;
            //FormatString(range);
            sheet = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_obj = sheet.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheet, new object[] { rangeBefore });
            range_obj.GetType().InvokeMember("Copy", BindingFlags.InvokeMethod, null, range_obj, null);
            object[] args = new object[4];

            //format TypePaste values
            //xlPasteValues = -4163,
            //xlPasteFormats = -4122,
            //xlPasteAll = -4104,
            args[0] = -4104; //format TypePaste values
            args[1] = -4142;//Excel.XlPasteSpecialOperation.xlPasteSpecialOperationNone
            args[2] = false;
            args[3] = false;
            sheetto = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_to = sheetto.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheetto, new object[] { rangeAfter });
            range_to.GetType().InvokeMember("PasteSpecial", BindingFlags.InvokeMethod, null, range_to, args);

        }

        private void FormatString(string range)
        {
            object sheet;
            object range_obj;

            sheet = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_obj = sheet.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheet, new object[] { range });
            range_obj.GetType().InvokeMember("Copy", BindingFlags.SetProperty, null, range_obj, new object[] { "@" }, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void Visibility(bool visible)
        {
            ExcelApplication.GetType().InvokeMember("Visible", BindingFlags.SetProperty, null, ExcelApplication, new object[] { visible }, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }

        public void ProtectSheet(bool visible)
        {

        }

        public string CellsRead(string range)
        {
            object sheet;
            object range_obj;

            sheet = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_obj = sheet.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheet, new object[] { range });
            if (range_obj.GetType().InvokeMember("Value", BindingFlags.GetProperty, null, range_obj, null, System.Globalization.CultureInfo.CreateSpecificCulture("en-US")) == null)
                return "";
            else
                return range_obj.GetType().InvokeMember("Value", BindingFlags.GetProperty, null, range_obj, null, System.Globalization.CultureInfo.CreateSpecificCulture("en-US")).ToString();

        }

        public string GetExcelColumnName(int columnNumber)
        {
            int dividend = columnNumber;
            string columnName = String.Empty;
            int modulo;

            while (dividend > 0)
            {
                modulo = (dividend - 1) % 26;
                columnName = Convert.ToChar(65 + modulo).ToString() + columnName;
                dividend = (int)((dividend - modulo) / 26);
            }

            return columnName;
        }

        public bool FindText(string text)
        {
            object sheet;
            object range_obj;
            object cellsobj;

            sheet = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_obj = sheet.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheet, new object[] { "A1", "C4" }, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
            cellsobj = range_obj.GetType().InvokeMember("Find", BindingFlags.InvokeMethod, null, range_obj, new object[] { text }, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
            if (cellsobj != null)
                return true;
            else
                return false;
        }

        public int GetNumberOfSheets()
        {
            object sheets = oBook.GetType().InvokeMember("Sheets", BindingFlags.GetProperty, null, oBook, null);
            return Convert.ToInt32(sheets.GetType().InvokeMember("Count", BindingFlags.GetProperty, null, sheets, null));
        }

        public void CellsBorder(string range)
        {
            object sheet;
            object range_obj;
            object border_obj;

            sheet = oBook.GetType().InvokeMember("ActiveSheet", BindingFlags.GetProperty, null, oBook, null);
            range_obj = sheet.GetType().InvokeMember("Range", BindingFlags.GetProperty, null, sheet, new object[] { range });
            border_obj = range_obj.GetType().InvokeMember("Borders", BindingFlags.GetProperty, null, range_obj, new object[] { 7 });
            border_obj.GetType().InvokeMember("LineStyle", BindingFlags.SetProperty, null, border_obj, new object[] { 1 });
            border_obj.GetType().InvokeMember("Weight", BindingFlags.SetProperty, null, border_obj, new object[] { 2 });
            border_obj.GetType().InvokeMember("ColorIndex", BindingFlags.SetProperty, null, border_obj, new object[] { -4105 });
            border_obj = range_obj.GetType().InvokeMember("Borders", BindingFlags.GetProperty, null, range_obj, new object[] { 8 });
            border_obj.GetType().InvokeMember("LineStyle", BindingFlags.SetProperty, null, border_obj, new object[] { 1 });
            border_obj.GetType().InvokeMember("Weight", BindingFlags.SetProperty, null, border_obj, new object[] { 2 });
            border_obj.GetType().InvokeMember("ColorIndex", BindingFlags.SetProperty, null, border_obj, new object[] { -4105 });
            border_obj = range_obj.GetType().InvokeMember("Borders", BindingFlags.GetProperty, null, range_obj, new object[] { 9 });
            border_obj.GetType().InvokeMember("LineStyle", BindingFlags.SetProperty, null, border_obj, new object[] { 1 });
            border_obj.GetType().InvokeMember("Weight", BindingFlags.SetProperty, null, border_obj, new object[] { 2 });
            border_obj.GetType().InvokeMember("ColorIndex", BindingFlags.SetProperty, null, border_obj, new object[] { -4105 });
            border_obj = range_obj.GetType().InvokeMember("Borders", BindingFlags.GetProperty, null, range_obj, new object[] { 10 });
            border_obj.GetType().InvokeMember("LineStyle", BindingFlags.SetProperty, null, border_obj, new object[] { 1 });
            border_obj.GetType().InvokeMember("Weight", BindingFlags.SetProperty, null, border_obj, new object[] { 2 });
            border_obj.GetType().InvokeMember("ColorIndex", BindingFlags.SetProperty, null, border_obj, new object[] { -4105 });
        }
    }
}
