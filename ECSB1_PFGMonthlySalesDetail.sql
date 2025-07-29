Create view "ECSB1_PFGMonthlySalesDetail" AS

SELECT 
	 'A' AS "Format Version",
	 '' AS "Supplier Number",
	 T2."U_UNIPROID" AS "Member Number",
	 T3."U_MemberLocNo" AS "Member Location Number",
	 T2."U_DUNS" AS "Member Duns Number",
	 T2."CardName" AS "Member Name",
	 '' AS "Member GLN Number",
	 T0."DocNum" AS "Supplier Invoice Number",
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
	 .01 * t2."U_BuyingGroup" AS "EDA Rate",
	 t1."LineTotal" * .01 * t2."U_BuyingGroup" AS "EDA Payment",
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
	 t1."ItemCode" AS "Manufacturer's Item Number",
	 t5."FirmName" AS "Manufacturer's Name" 
	FROM "OINV" T0 
	INNER JOIN "INV1" T1 ON T0."DocEntry" = T1."DocEntry" 
	INNER JOIN "OCRD" T2 ON T0."CardCode" = T2."CardCode" 
	LEFT OUTER JOIN "CRD1" T3 ON T2."CardCode" = T3."CardCode" 
		AND t0."ShipToCode" = t3."Address" 
		AND t3."AdresType" = 'S' 
	INNER JOIN "OITM" t4 ON t1."ItemCode" = t4."ItemCode" 
	LEFT OUTER JOIN "OMRC" t5 ON t4."FirmCode" = t5."FirmCode" 
	WHERE T0."CANCELED" = 'N' 
	AND t2."GroupCode" = 130 --119
	AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-2)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-1))
	
UNION ALL
	
SELECT 

	 'A' AS "Format Version",
	 '' AS "Supplier Number",
	 T2."U_UNIPROID" AS "Member Number",
	 T3."U_MemberLocNo" AS "Member Location Number",
	 T2."U_DUNS" AS "Member Duns Number",
	 T2."CardName" AS "Member Name",
	 '' AS "Member GLN Number",
	 T0."DocNum" AS "Supplier Invoice Number",
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
	 .01 * t2."U_BuyingGroup" AS "EDA Rate",
	 -t1."LineTotal" * .01 * t2."U_BuyingGroup" AS "EDA Payment",
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
	 t1."ItemCode" AS "Manufacturer's Item Number",
	 t5."FirmName" AS "Manufacturer's Name" 
	FROM "ORIN" T0 
	INNER JOIN "RIN1" T1 ON T0."DocEntry" = T1."DocEntry" 
	INNER JOIN "OCRD" T2 ON T0."CardCode" = T2."CardCode" 
	LEFT OUTER JOIN "CRD1" T3 ON T2."CardCode" = T3."CardCode" 
	AND t0."ShipToCode" = t3."Address" 
	AND t3."AdresType" = 'S' 
	INNER JOIN "OITM" t4 ON t1."ItemCode" = t4."ItemCode" 
	LEFT OUTER JOIN "OMRC" t5 ON t4."FirmCode" = t5."FirmCode" 
	WHERE T0."CANCELED" = 'N' 
	AND t2."GroupCode" = 130 --119
	AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-2)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-1))