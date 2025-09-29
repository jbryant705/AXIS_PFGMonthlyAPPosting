alter view "ECSB1_RDAMonthlySales" AS

--Invoices
SELECT
	 t8."GroupName" AS "Group",
	 t2."GroupCode",
	 'Axis Redistribution/Boss Cleaning Equipment' AS "RDA Company",
	 T2."CardCode",
	 T2."CardName",
	 t3."City" AS "City",
	 t3."State" AS "State",
	 T0."DocNum" AS "Supplier Invoice Number",
	 t1."VisOrder",
	 T0."DocDate" AS "Invoice Date",
	 t7."Date Invoice Paid",
	 t1."ItemCode",
	 t1."SubCatNum",
	 t1."Dscription",
	 t1."unitMsr" "UOM",
	 CASE WHEN t7."Date Invoice Paid" IS NULL 
AND DAYS_BETWEEN(t0."DocDate",
	 current_date) <= 45 
THEN 'N/A' 
WHEN DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45 
THEN 'Y' 
WHEN t2."GroupCode" = 121 then 'Y'
ELSE 'N' 
END AS "Eligible For Rebate Y/N",
	 t1."Quantity" AS "Cases",
	 t1."LineTotal" AS "Gross Invoice Dollars",
	 t1."LineTotal" AS "Net Invoice Dollars",
	 (CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45) 
THEN t2."U_BuyingGroup" 
ELSE 
	(case when t2."GroupCode" = 121 then 1 else 0 end)
END) AS "EDA %",
	 t1."LineTotal" * .01 *
	 (CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45) 
THEN t2."U_BuyingGroup" 
ELSE 
	(case when t2."GroupCode" = 121 then 1 else 0 end)
END) AS "Rebate Amount" 
FROM "OINV" T0 
INNER JOIN "INV1" T1 ON T0."DocEntry" = T1."DocEntry" 
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
INNER JOIN "OCRG" t8 ON t2."GroupCode" = t8."GroupCode" 
WHERE T0."CANCELED" = 'N' 
AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-3)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-2))

UNION ALL

--Credits
SELECT
	 t8."GroupName" AS "Group",
	 t2."GroupCode",
	 'Axis Redistribution/Boss Cleaning Equipment' AS "RDA Company",
	 T2."CardCode",
	 T2."CardName",
	 t3."City" AS "City",
	 t3."State" AS "State",
	 T0."DocNum" AS "Supplier Invoice Number",
	 t1."VisOrder",
	 T0."DocDate" AS "Invoice Date",
	 t7."Date Invoice Paid",
	 t1."ItemCode",
	 t1."SubCatNum",
	 t1."Dscription",
	 t1."unitMsr" "UOM",
	 CASE WHEN t7."Date Invoice Paid" IS NULL 
AND DAYS_BETWEEN(t0."DocDate",
	 current_date) <= 45 
THEN 'N/A' 
WHEN DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45 
THEN 'Y' 
WHEN t2."GroupCode" = 121 then 'Y'
ELSE 'N' 
END AS "Eligible For DPA Y/N",
	 t1."Quantity" AS "Cases",
	 -t1."LineTotal" AS "Gross Invoice Dollars",
	 -t1."LineTotal" AS "Net Invoice Dollars",
	 (CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45) 
THEN t2."U_BuyingGroup" 
ELSE 
	(case when t2."GroupCode" = 121 then 1 else 0 end)
END) AS "EDA %",
	 -t1."LineTotal" *.01 *
	 (CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45) 
THEN t2."U_BuyingGroup" 
ELSE 
	(case when t2."GroupCode" = 121 then 1 else 0 end)
END) AS "Rebate Amount" 
FROM "ORIN" T0 
INNER JOIN "RIN1" T1 ON T0."DocEntry" = T1."DocEntry" 
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
INNER JOIN "OCRG" t8 ON t2."GroupCode" = t8."GroupCode" 
WHERE T0."CANCELED" = 'N'
AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-3)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-2)) 

UNION ALL

-- Negative Freight on Invoices
SELECT
	 t8."GroupName" AS "Group",
	 t2."GroupCode",
	 'Axis Redistribution/Boss Cleaning Equipment' AS "RDA Company",
	 T2."CardCode",
	 T2."CardName",
	 t3."City" AS "City",
	 t3."State" AS "State",
	 T0."DocNum" AS "Supplier Invoice Number",
	 9999 as "Visorder",
	 T0."DocDate" AS "Invoice Date",
	 t7."Date Invoice Paid",
	 'Freight Credit' AS "ItemCode",
	 '' as "SubCatNum",
	 'Freight Credit' AS "Dscription",
	 '' "UOM",
	 CASE WHEN t7."Date Invoice Paid" IS NULL 
AND DAYS_BETWEEN(t0."DocDate",
	 current_date) <= 45 
THEN 'N/A' 
WHEN DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45 
THEN 'Y' 
WHEN t2."GroupCode" = 121 then 'Y'
ELSE 'N' 
END AS "Eligible For Rebate Y/N",
	 0 AS "Cases",
	 0 AS "Gross Invoice Dollars",
	 t1."LineTotal" AS "Net Invoice Dollars",
	 (CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45) 
THEN t2."U_BuyingGroup" 
ELSE 
	(case when t2."GroupCode" = 121 then 1 else 0 end)
END) AS "EDA %",
	 t1."LineTotal" * .01 *
	 (CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45) 
THEN t2."U_BuyingGroup" 
ELSE 
	(case when t2."GroupCode" = 121 then 1 else 0 end)
END) AS "Rebate Amount" 
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
INNER JOIN "OCRG" t8 ON t2."GroupCode" = t8."GroupCode" 
WHERE T0."CANCELED" = 'N' 
AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-3)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-2))
AND t1."LineTotal" < 0

UNION ALL

-- Negative Freight on Credits
SELECT
	 t8."GroupName" AS "Group",
	 t2."GroupCode",
	 'Axis Redistribution/Boss Cleaning Equipment' AS "RDA Company",
	 T2."CardCode",
	 T2."CardName",
	 t3."City" AS "City",
	 t3."State" AS "State",
	 T0."DocNum" AS "Supplier Invoice Number",
	 9999 as "VisOrder",
	 T0."DocDate" AS "Invoice Date",
	 t7."Date Invoice Paid",
	 'Freight Credit' AS "ItemCode",
	 '' as "SubCatNum",
	 'Freight Credit' AS "Dscription",
	 '' "UOM",
	 CASE WHEN t7."Date Invoice Paid" IS NULL 
AND DAYS_BETWEEN(t0."DocDate",
	 current_date) <= 45 
THEN 'N/A' 
WHEN DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45 
THEN 'Y' 
WHEN t2."GroupCode" = 121 then 'Y'
ELSE 'N' 
END AS "Eligible For DPA Y/N",
	 0 AS "Cases",
	 0 AS "Gross Invoice Dollars",
	 -t1."LineTotal" AS "Net Invoice Dollars",
	 (CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45) 
THEN t2."U_BuyingGroup" 
ELSE 
	(case when t2."GroupCode" = 121 then 1 else 0 end)
END) AS "EDA %",
	 -t1."LineTotal" *.01 *
	 (CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	 t7."Date Invoice Paid") <= 45) 
THEN t2."U_BuyingGroup" 
ELSE 
	(case when t2."GroupCode" = 121 then 1 else 0 end)
END) AS "Rebate Amount" 
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
INNER JOIN "OCRG" t8 ON t2."GroupCode" = t8."GroupCode" 
WHERE T0."CANCELED" = 'N'
AND T0."DocDate" >= ADD_DAYS(last_day(ADD_MONTHS(current_date,-3)),+1) and T0."DocDate" <= last_day(ADD_MONTHS(current_date,-2)) 
AND t1."LineTotal" < 0