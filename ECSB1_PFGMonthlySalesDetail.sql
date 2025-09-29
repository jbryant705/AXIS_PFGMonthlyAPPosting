alter view "ECSB1_PFGMonthlySalesDetail" AS

--Invoices
SELECT 
	'A' AS "Format Version",
	'' AS "Supplier Number",
	T2."U_UNIPROID" AS "Member Number",
	T3."U_MemberLocNo" AS "Member Location Number",
	T2."U_DUNS" AS "Member Duns Number",
	T2."CardName" AS "Member Name",
	'' AS "Member GLN Number",
	T0."DocNum" AS "Supplier Invoice Number",
	t1."VisOrder",
	T0."NumAtCard" AS "Member PO Number",
	T0."DocDate" AS "Invoice Date",
	'' AS "Original Manufacturer DUNs Number",
	T1."ItemCode" AS "Supplier Product Number",
	T1."unitMsr" AS "Pack/Size",
	t5."FirmName" AS "Brand",
	left(t1."Dscription",45) "Item Description",
	'' AS "GTIN Number",
	t4."CodeBars" AS "UPC Code",
	t1."Quantity" AS "Cases",
	t1."Weight1" AS "Weight",
	t1."LineTotal" AS "Gross Sales",
	t1."LineTotal" AS "Net Sales",
	(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t2."U_BuyingGroup" 
	ELSE 0
	END) AS "EDA Rate",
	t1."LineTotal" * .01 *
	(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t2."U_BuyingGroup" 
	ELSE 0
	END) AS "EDA Payment",
	.01 * t2."U_RebatePct" AS "SPA Rate",
	'' AS "SPA Payment",
	'' AS "Show Special Rate",
	'' AS "Show Special Payment",
	'' AS "Other Rate",
	'' AS "Other Payment",
	'' AS "Drop Ship Paid To",
	'' AS "Deduction Code",
	'' AS "Member Billback Number",
	'' AS "Reason for Deduction",
	t3."Street" AS "Member Ship To Address",
	t3."City" AS "Member Ship To City",
	t3."State" AS "Member Ship To State",
	'' AS "CaRMA Check #",
	t1."Price" AS "Unit Price",
	'' AS "Product Line ID",
	'' AS "Internal Vendor Number",
	t1."SubCatNum" AS "Manufacturer's Item Number",
	t5."FirmName" AS "Manufacturer's Name" 
	FROM "OINV" T0 
	INNER JOIN "INV1" T1 ON T0."DocEntry" = T1."DocEntry" 
	INNER JOIN "OCRD" T2 ON T0."CardCode" = T2."CardCode" 
	LEFT OUTER JOIN "CRD1" T3 ON T2."CardCode" = T3."CardCode" 
		AND t0."ShipToCode" = t3."Address" 
		AND t3."AdresType" = 'S' 
	INNER JOIN "OITM" t4 ON t1."ItemCode" = t4."ItemCode" 
	LEFT OUTER JOIN "OMRC" t5 ON t4."FirmCode" = t5."FirmCode" 
	LEFT OUTER JOIN (SELECT
	 t4."SrcObjAbs",
	 MAX(t5."ReconDate") AS "Date Invoice Paid" 
	FROM "ITR1" t4 
	INNER JOIN "OITR" t5 ON t4."ReconNum" = t5."ReconNum" 
	WHERE t4."SrcObjTyp" = 13 
	GROUP BY t4."SrcObjAbs") t7 ON t7."SrcObjAbs" = t0."DocEntry" 
	WHERE T0."CANCELED" = 'N' 
	AND t2."GroupCode" = 130
	AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-2)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-1))
	
UNION ALL

--Credits
SELECT 
	'A' AS "Format Version",
	'' AS "Supplier Number",
	T2."U_UNIPROID" AS "Member Number",
	T3."U_MemberLocNo" AS "Member Location Number",
	T2."U_DUNS" AS "Member Duns Number",
	T2."CardName" AS "Member Name",
	'' AS "Member GLN Number",
	T0."DocNum" AS "Supplier Invoice Number",
	T1."VisOrder",
	T0."NumAtCard" AS "Member PO Number",
	T0."DocDate" AS "Invoice Date",
	'' AS "Original Manufacturer DUNs Number",
	T1."ItemCode" AS "Supplier Product Number",
	T1."unitMsr" AS "Pack/Size",
	t5."FirmName" AS "Brand",
	left(t1."Dscription",45) "Item Description",
	'' AS "GTIN Number",
	t4."CodeBars" AS "UPC Code",
	-t1."Quantity" AS "Cases",
	t1."Weight1" AS "Weight",
	-t1."LineTotal" AS "Gross Sales",
	-t1."LineTotal" AS "Net Sales",
	(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t2."U_BuyingGroup" 
	else 0
	END) AS "EDA Rate",
	-t1."LineTotal" * .01 *
	(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t2."U_BuyingGroup" 
	ELSE 0
	END) AS "EDA Payment",
	.01 * t2."U_RebatePct" AS "SPA Rate",
	'' AS "SPA Payment",
	'' AS "Show Special Rate",
	'' AS "Show Special Payment",
	'' AS "Other Rate",
	'' AS "Other Payment",
	'' AS "Drop Ship Paid To",
	'' AS "Deduction Code",
	'' AS "Member Billback Number",
	'' AS "Reason for Deduction",
	t3."Street" AS "Member Ship To Address",
	t3."City" AS "Member Ship To City",
	t3."State" AS "Member Ship To State",
	'' AS "CaRMA Check #",
	-t1."Price" AS "Unit Price",
	'' AS "Product Line ID",
	'' AS "Internal Vendor Number",
	t1."SubCatNum" AS "Manufacturer's Item Number",
	t5."FirmName" AS "Manufacturer's Name" 
	FROM "ORIN" T0 
	INNER JOIN "RIN1" T1 ON T0."DocEntry" = T1."DocEntry" 
	INNER JOIN "OCRD" T2 ON T0."CardCode" = T2."CardCode" 
	LEFT OUTER JOIN "CRD1" T3 ON T2."CardCode" = T3."CardCode" 
	AND t0."ShipToCode" = t3."Address" 
	AND t3."AdresType" = 'S' 
	INNER JOIN "OITM" t4 ON t1."ItemCode" = t4."ItemCode" 
	LEFT OUTER JOIN "OMRC" t5 ON t4."FirmCode" = t5."FirmCode" 
	LEFT OUTER JOIN (SELECT
	 t4."SrcObjAbs",
	 MAX(t5."ReconDate") AS "Date Invoice Paid" 
	FROM "ITR1" t4 
	INNER JOIN "OITR" t5 ON t4."ReconNum" = t5."ReconNum" 
	WHERE t4."SrcObjTyp" = 14 
	GROUP BY t4."SrcObjAbs") t7 ON t7."SrcObjAbs" = t0."DocEntry" 
	WHERE T0."CANCELED" = 'N' 
	AND t2."GroupCode" = 130
	AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-2)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-1))

UNION ALL

-- Negative Freight on Invoices
SELECT 
	'A' AS "Format Version",
	'' AS "Supplier Number",
	T2."U_UNIPROID" AS "Member Number",
	T3."U_MemberLocNo" AS "Member Location Number",
	T2."U_DUNS" AS "Member Duns Number",
	T2."CardName" AS "Member Name",
	'' AS "Member GLN Number",
	T0."DocNum" AS "Supplier Invoice Number",
	9999 AS "VisOrder",
	T0."NumAtCard" AS "Member PO Number",
	T0."DocDate" AS "Invoice Date",
	'' AS "Original Manufacturer DUNs Number",
	'Freight Credit' AS "Supplier Product Number",
	'' AS "Pack/Size",
	'' AS "Brand",
	'Freight Credit' AS "Item Description",
	'' AS "GTIN Number",
	'' AS "UPC Code",
	0 AS "Cases",
	0 AS "Weight",
	0 AS "Gross Sales",
	t1."LineTotal" AS "Net Sales",
	(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t2."U_BuyingGroup" 
	else 0
	END) AS "EDA Rate",
	t1."LineTotal" * .01 *
	(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t2."U_BuyingGroup" 
	ELSE 0
	END) AS "EDA Payment",
	.01 * t2."U_RebatePct" AS "SPA Rate",
	'' AS "SPA Payment",
	'' AS "Show Special Rate",
	'' AS "Show Special Payment",
	'' AS "Other Rate",
	'' AS "Other Payment",
	'' AS "Drop Ship Paid To",
	'' AS "Deduction Code",
	'' AS "Member Billback Number",
	'' AS "Reason for Deduction",
	t3."Street" AS "Member Ship To Address",
	t3."City" AS "Member Ship To City",
	t3."State" AS "Member Ship To State",
	'' AS "CaRMA Check #",
	t1."LineTotal" AS "Unit Price",
	'' AS "Product Line ID",
	'' AS "Internal Vendor Number",
	'Freight Credit' AS "Manufacturer's Item Number",
	'' AS "Manufacturer's Name" 
	FROM "OINV" T0 
	INNER JOIN "INV3" T1 ON T0."DocEntry" = T1."DocEntry" 
	INNER JOIN "OCRD" T2 ON T0."CardCode" = T2."CardCode" 
	LEFT OUTER JOIN "CRD1" T3 ON T2."CardCode" = T3."CardCode" 
		AND t0."ShipToCode" = t3."Address" 
		AND t3."AdresType" = 'S' 
	LEFT OUTER JOIN (SELECT
	 t4."SrcObjAbs",
	 MAX(t5."ReconDate") AS "Date Invoice Paid" 
	FROM "ITR1" t4 
	INNER JOIN "OITR" t5 ON t4."ReconNum" = t5."ReconNum" 
	WHERE t4."SrcObjTyp" = 13 
	GROUP BY t4."SrcObjAbs") t7 ON t7."SrcObjAbs" = t0."DocEntry" 
	WHERE T0."CANCELED" = 'N' 
	AND t2."GroupCode" = 130
	AND t1."LineTotal" < 0
	AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-2)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-1))
	
UNION ALL
	
-- Negative Freight on Credits
SELECT 
	'A' AS "Format Version",
	'' AS "Supplier Number",
	T2."U_UNIPROID" AS "Member Number",
	T3."U_MemberLocNo" AS "Member Location Number",
	T2."U_DUNS" AS "Member Duns Number",
	T2."CardName" AS "Member Name",
	'' AS "Member GLN Number",
	T0."DocNum" AS "Supplier Invoice Number",
	9999 AS "VisOrder",
	T0."NumAtCard" AS "Member PO Number",
	T0."DocDate" AS "Invoice Date",
	'' AS "Original Manufacturer DUNs Number",
	'Freight Credit' AS "Supplier Product Number",
	'' AS "Pack/Size",
	'' AS "Brand",
	'Freight Credit' AS "Item Description",
	'' AS "GTIN Number",
	'' AS "UPC Code",
	0 AS "Cases",
	0 AS "Weight",
	0 AS "Gross Sales",
	-t1."LineTotal" AS "Net Sales",
	(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t2."U_BuyingGroup" 
	else 0
	END) AS "EDA Rate",
	-t1."LineTotal" * .01 *
	(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t2."U_BuyingGroup" 
	ELSE 0
	END) AS "EDA Payment",
	.01 * t2."U_RebatePct" AS "SPA Rate",
	'' AS "SPA Payment",
	'' AS "Show Special Rate",
	'' AS "Show Special Payment",
	'' AS "Other Rate",
	'' AS "Other Payment",
	'' AS "Drop Ship Paid To",
	'' AS "Deduction Code",
	'' AS "Member Billback Number",
	'' AS "Reason for Deduction",
	t3."Street" AS "Member Ship To Address",
	t3."City" AS "Member Ship To City",
	t3."State" AS "Member Ship To State",
	'' AS "CaRMA Check #",
	-t1."LineTotal" AS "Unit Price",
	'' AS "Product Line ID",
	'' AS "Internal Vendor Number",
	'Freight Credit' AS "Manufacturer's Item Number",
	'' AS "Manufacturer's Name" 
	FROM "ORIN" T0 
	INNER JOIN "RIN3" T1 ON T0."DocEntry" = T1."DocEntry" 
	INNER JOIN "OCRD" T2 ON T0."CardCode" = T2."CardCode" 
	LEFT OUTER JOIN "CRD1" T3 ON T2."CardCode" = T3."CardCode" 
	AND t0."ShipToCode" = t3."Address" 
	AND t3."AdresType" = 'S' 
	LEFT OUTER JOIN (SELECT
	 t4."SrcObjAbs",
	 MAX(t5."ReconDate") AS "Date Invoice Paid" 
	FROM "ITR1" t4 
	INNER JOIN "OITR" t5 ON t4."ReconNum" = t5."ReconNum" 
	WHERE t4."SrcObjTyp" = 14 
	GROUP BY t4."SrcObjAbs") t7 ON t7."SrcObjAbs" = t0."DocEntry" 
	WHERE T0."CANCELED" = 'N' 
	AND t2."GroupCode" = 130
	AND t1."LineTotal" < 0
	AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-2)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-1))