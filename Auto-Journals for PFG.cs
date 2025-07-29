//Using / Imports - System.IO;System.Text;
var ufCode = "UF-220";
var ufName = "Auto PFG Journal Entries";
var companyDB = company.CompanyDB;
var today = DateTime.Today;
var now = DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss");
var nowshort = DateTime.Now.ToString("MM/dd/yyyy");
var res = 0;
var logFileDir = string.Format(@"\\adm\c$\Program Files\ECSB1\{0}\{1}\", companyDB, ufName);
var logFileName = string.Format("{0}_{1}_{2}.txt", ufCode, ufName, DateTime.Now.ToString("yyyyMMdd"));
var logFilePath = logFileDir + logFileName;
var logEntry = new StringBuilder();

try
{
    // Create log directory if it doesn't exist
    Directory.CreateDirectory(logFileDir);

    SAPbobsCOM.Recordset rs_BP = (SAPbobsCOM.Recordset)company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);
    var sql_BP = string.Format(@"select * from ""ECSB1_PFGMonthlyAPPosting""");

    rs_BP.DoQuery(sql_BP);

    // Check if query returned no results
    if (rs_BP.RecordCount == 0)
    {
        logEntry.Clear();
        logEntry.AppendFormat("{0}\t- INFO - No records found in ECSB1_PFGMonthlyAPPosting for processing", now);
        using (FileStream fs = new FileStream(logFilePath, FileMode.Append, FileAccess.Write))
        using (StreamWriter sw = new StreamWriter(fs))
        {
            sw.WriteLine(logEntry.ToString());
        }
        System.Runtime.InteropServices.Marshal.ReleaseComObject(rs_BP);
        return; // Exit the method since no records to process
    }

    while (!rs_BP.EoF)
    {
        // Create a new JournalEntries object for each record
        SAPbobsCOM.JournalEntries Journal = (SAPbobsCOM.JournalEntries)company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oJournalEntries);

        var cardCode = (string)rs_BP.Fields.Item("CardCode").Value;
        var MemberName = (string)rs_BP.Fields.Item("Member Name").Value;
        var AcctCode = (string)rs_BP.Fields.Item("AcctCode").Value;
        var Rebate = (double)rs_BP.Fields.Item("Rebate Amount").Value;
        var PostingDate = today;

        // Header
        Journal.ReferenceDate = PostingDate;
        Journal.TaxDate = PostingDate;
        Journal.DueDate = PostingDate;
        Journal.Memo = "PFG Rebates for " + MemberName + " " + nowshort;

        // First Line (Debit)
        Journal.Lines.AccountCode = AcctCode;
        Journal.Lines.Credit = Rebate;
        Journal.Lines.Add(); // Add the first line to the journal entry

        // Second Line (Credit - Offset to _SYS00000000321)
        Journal.Lines.AccountCode = "_SYS00000000321"; // Customer Rebates
        Journal.Lines.Debit = Rebate; // Credit the same amount to balance the entry
        Journal.Lines.Add(); // Add the second line to the journal entry

        res = Journal.Add();

        var newDocEntry = Convert.ToInt32(company.GetNewObjectKey());

        if (res != 0)
        {
            logEntry.Clear();
            logEntry.AppendFormat("{0}\t- ERROR - Failed to add Journal Entry for CardCode {1}:\t{2}", now, cardCode, company.GetLastErrorDescription());
            using (FileStream fs = new FileStream(logFilePath, FileMode.Append, FileAccess.Write))
            using (StreamWriter sw = new StreamWriter(fs))
            {
                sw.WriteLine(logEntry.ToString());
            }
        }
        else
        {
            logEntry.Clear();
            logEntry.AppendFormat("{0}\t- SUCCESS - Successfully added Journal Entry for {1} with DocEntry {2}", now, cardCode, newDocEntry);
            using (FileStream fs = new FileStream(logFilePath, FileMode.Append, FileAccess.Write))
            using (StreamWriter sw = new StreamWriter(fs))
            {
                sw.WriteLine(logEntry.ToString());
            }
        }

        // Release the Journal object after each iteration
        System.Runtime.InteropServices.Marshal.ReleaseComObject(Journal);
        rs_BP.MoveNext();        
    }

    System.Runtime.InteropServices.Marshal.ReleaseComObject(rs_BP);
}

catch (System.Exception e)
{
    logEntry.Clear();
    logEntry.AppendFormat("{0}\t- EXCEPTION - {1}", now, e.Message);
    using (FileStream fs = new FileStream(logFilePath, FileMode.Append, FileAccess.Write))
    using (StreamWriter sw = new StreamWriter(fs))
    {
        sw.WriteLine(logEntry.ToString());
    }
}