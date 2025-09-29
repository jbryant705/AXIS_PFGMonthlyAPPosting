alter VIEW "AXIS"."ECSB1_PFGMonthlyAPPosting" AS

SELECT
    a."CardCode",
    a."Member Name",
    -- Net sales (from subquery 'a')
    -- a."Net Sales",
    r."Rebate Type",
    r."AcctCode",
    CASE r."Rebate Type"
        WHEN 'Rebate-01' THEN '2.25% PFG / AFFLINK Rebate'
        WHEN 'Rebate-02' THEN '.5% PFG Growth Rebate'
        WHEN 'Rebate-03' THEN '3% PFG Corporate Rebate'
        WHEN 'Rebate-04' THEN '4% PFG Specilists Rebate'
        WHEN 'Rebate-05' THEN '.25% PFG Show Allowance - Disposables'
        WHEN 'Rebate-06' THEN '.25% PFG Show Allowance - E&S'
    END AS "Rebate Description",
    coa."Segment_0" || '-' || coa."Segment_1" || '-' || coa."Segment_2" || '-' || coa."Segment_3" AS "Account",
    CAST(
        CASE r."Rebate Type"
            -- 23200001-01-001-01 - Accrued Expense PFG / AFFLINK Rebate 2.25% (2% PFG, .25% AFFLINK)
            -- Applies to C03282 Disposables & C03283 E&S
            WHEN 'Rebate-01' THEN SUM(a."Net Sales") * 0.0225

            -- 23200002-01-001-01 - Accrued Expenses PFG Growth Rebate .5%
            -- Applies to C03282 Disposables & C03283 E&S
            WHEN 'Rebate-02' THEN SUM(a."Net Sales") * 0.005

            -- 23200003-01-001-01 - Accrued Expenses PFG Corporate Rebate 3.00%
            WHEN 'Rebate-03' THEN
                SUM(a."Net Sales") * (
                    CASE WHEN a."CardCode" IN ('C03361', 'C03362', 'C03364') THEN 0.03 ELSE 0 END
                )

            -- 23200004-01-001-01 - Accrued Expenses PFG Specialists Rebate 4.00%
            WHEN 'Rebate-04' THEN
                SUM(a."Net Sales") * (
                    CASE WHEN a."CardCode" IN ('C03361', 'C03362', 'C03364') THEN 0.04 ELSE 0 END
                )

            -- 23200005-01-001-01 - Accrued Expense .25% PFG Show Allowance - Disposables
            -- Cheney Only: applies to C03282, C03283
            WHEN 'Rebate-05' THEN
                SUM(a."Net Sales") * (
                    CASE WHEN a."CardCode" IN ('C03282', 'C03283') THEN 0.0025 ELSE 0 END
                )

            -- 23200006-01-001-01 - Accrued Expense .25% PFG Show Allowance - E&S
            -- Cheney Only: applies to C03282, C03283
            WHEN 'Rebate-06' THEN
                SUM(a."Net Sales") * (
                    CASE WHEN a."CardCode" IN ('C03282', 'C03283') THEN 0.0025 ELSE 0 END
                )
        END AS DECIMAL(19,2)
    ) AS "Rebate Amount"
FROM (
    --Invoices
	SELECT
        t2."CardCode",
        t2."CardName" AS "Member Name",
        sum(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t1."LineTotal" ELSE 0 END) AS "Net Sales"
    FROM "OINV" t0
    INNER JOIN "INV1" t1 ON t0."DocEntry" = t1."DocEntry"
    INNER JOIN "OCRD" t2 ON t0."CardCode" = t2."CardCode"
	LEFT OUTER JOIN (SELECT
	 t4."SrcObjAbs",
	 MAX(t5."ReconDate") AS "Date Invoice Paid" 
	FROM "ITR1" t4 
	INNER JOIN "OITR" t5 ON t4."ReconNum" = t5."ReconNum" 
	WHERE t4."SrcObjTyp" = 13 
	GROUP BY t4."SrcObjAbs") t7 ON t7."SrcObjAbs" = t0."DocEntry"
    WHERE t0."CANCELED" = 'N'
      AND t0."DocType" = 'I'
      AND t2."GroupCode" = 130
      /*
	  AND t0."DocDate" >= ADD_DAYS(LAST_DAY(ADD_MONTHS(CURRENT_DATE, -2)), +1)
      AND t0."DocDate" <= LAST_DAY(ADD_MONTHS(CURRENT_DATE, -1))
	  */
	and month(T0."DocDate") = month(current_date) 
	and year(T0."DocDate") = year(current_date) 
	 GROUP BY t2."CardCode", t2."CardName"

    UNION ALL
	--Credit Memos
    SELECT
        t2."CardCode",
        t2."CardName" AS "Member Name",
        -sum(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t1."LineTotal" ELSE 0 END) AS "Net Sales"
    FROM "ORIN" t0
    INNER JOIN "RIN1" t1 ON t0."DocEntry" = t1."DocEntry"
    INNER JOIN "OCRD" t2 ON t0."CardCode" = t2."CardCode"
	LEFT OUTER JOIN (SELECT
	 t4."SrcObjAbs",
	 MAX(t5."ReconDate") AS "Date Invoice Paid" 
	FROM "ITR1" t4 
	INNER JOIN "OITR" t5 ON t4."ReconNum" = t5."ReconNum" 
	WHERE t4."SrcObjTyp" = 14
	GROUP BY t4."SrcObjAbs") t7 ON t7."SrcObjAbs" = t0."DocEntry"
    WHERE t0."CANCELED" = 'N'
	AND t0."DocType" = 'I'
		AND t2."GroupCode" = 130
      /*
	  AND t0."DocDate" >= ADD_DAYS(LAST_DAY(ADD_MONTHS(CURRENT_DATE, -2)), +1)
      AND t0."DocDate" <= LAST_DAY(ADD_MONTHS(CURRENT_DATE, -1))
	  */
	and month(T0."DocDate") = month(current_date) 
	and year(T0."DocDate") = year(current_date) 
	 GROUP BY t2."CardCode", t2."CardName"

	 UNION ALL
	 --Negative Freight on Invoices
	SELECT
        t2."CardCode",
        t2."CardName" AS "Member Name",
        sum(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t1."LineTotal" ELSE 0 END) AS "Net Sales"
    FROM "OINV" t0
    INNER JOIN "INV3" t1 ON t0."DocEntry" = t1."DocEntry"
    INNER JOIN "OCRD" t2 ON t0."CardCode" = t2."CardCode"
	LEFT OUTER JOIN (SELECT
	 t4."SrcObjAbs",
	 MAX(t5."ReconDate") AS "Date Invoice Paid" 
	FROM "ITR1" t4 
	INNER JOIN "OITR" t5 ON t4."ReconNum" = t5."ReconNum" 
	WHERE t4."SrcObjTyp" = 13 
	GROUP BY t4."SrcObjAbs") t7 ON t7."SrcObjAbs" = t0."DocEntry"
    WHERE t0."CANCELED" = 'N'
      AND t0."DocType" = 'I'
	  AND t1."LineTotal" < 0
      AND t2."GroupCode" = 130
      /*
	  AND t0."DocDate" >= ADD_DAYS(LAST_DAY(ADD_MONTHS(CURRENT_DATE, -2)), +1)
      AND t0."DocDate" <= LAST_DAY(ADD_MONTHS(CURRENT_DATE, -1))
	  */
	and month(T0."DocDate") = month(current_date) 
	and year(T0."DocDate") = year(current_date) 
	 GROUP BY t2."CardCode", t2."CardName"

    UNION ALL
	--Negative Freight on Credit Memos
    SELECT
        t2."CardCode",
        t2."CardName" AS "Member Name",
        -sum(CASE WHEN ( DAYS_BETWEEN(t0."DocDate",
	t7."Date Invoice Paid") <= 45) 
	THEN t1."LineTotal" ELSE 0 END) AS "Net Sales"
    FROM "ORIN" t0
    INNER JOIN "RIN3" t1 ON t0."DocEntry" = t1."DocEntry"
    INNER JOIN "OCRD" t2 ON t0."CardCode" = t2."CardCode"
	LEFT OUTER JOIN (SELECT
	 t4."SrcObjAbs",
	 MAX(t5."ReconDate") AS "Date Invoice Paid" 
	FROM "ITR1" t4 
	INNER JOIN "OITR" t5 ON t4."ReconNum" = t5."ReconNum" 
	WHERE t4."SrcObjTyp" = 14
	GROUP BY t4."SrcObjAbs") t7 ON t7."SrcObjAbs" = t0."DocEntry"
    WHERE t0."CANCELED" = 'N'
	AND t0."DocType" = 'I'
	AND t1."LineTotal" < 0
		AND t2."GroupCode" = 130
      /*
	  AND t0."DocDate" >= ADD_DAYS(LAST_DAY(ADD_MONTHS(CURRENT_DATE, -2)), +1)
      AND t0."DocDate" <= LAST_DAY(ADD_MONTHS(CURRENT_DATE, -1))
	  */
	and month(T0."DocDate") = month(current_date) 
	and year(T0."DocDate") = year(current_date) 
	 GROUP BY t2."CardCode", t2."CardName"
) a
CROSS JOIN (
    SELECT 'Rebate-01' AS "Rebate Type", '_SYS00000000373' AS "AcctCode" FROM DUMMY
    UNION ALL SELECT 'Rebate-02', '_SYS00000000374' FROM DUMMY
    UNION ALL SELECT 'Rebate-03', '_SYS00000000402' FROM DUMMY
    UNION ALL SELECT 'Rebate-04', '_SYS00000000403' FROM DUMMY
    UNION ALL SELECT 'Rebate-05', '_SYS00000000404' FROM DUMMY
    UNION ALL SELECT 'Rebate-06', '_SYS00000000405' FROM DUMMY
) r
INNER JOIN OACT coa ON r."AcctCode" = coa."AcctCode"
GROUP BY
    a."CardCode",
    a."Member Name",
    r."Rebate Type",
    r."AcctCode",
    coa."AcctName",
    coa."Segment_0" || '-' || coa."Segment_1" || '-' || coa."Segment_2" || '-' || coa."Segment_3"
HAVING
    CAST(
        CASE r."Rebate Type"
            WHEN 'Rebate-01' THEN SUM(a."Net Sales") * 0.0225
            WHEN 'Rebate-02' THEN SUM(a."Net Sales") * 0.005
            WHEN 'Rebate-03' THEN SUM(a."Net Sales") * (
                CASE WHEN a."CardCode" IN ('C03361', 'C03362', 'C03364') THEN 0.03 ELSE 0 END
            )
            WHEN 'Rebate-04' THEN SUM(a."Net Sales") * (
                CASE WHEN a."CardCode" IN ('C03361', 'C03362', 'C03364') THEN 0.04 ELSE 0 END
            )
            WHEN 'Rebate-05' THEN SUM(a."Net Sales") * (
                CASE WHEN a."CardCode" IN ('C03282', 'C03283') THEN 0.0025 ELSE 0 END
            )
            WHEN 'Rebate-06' THEN SUM(a."Net Sales") * (
                CASE WHEN a."CardCode" IN ('C03282', 'C03283') THEN 0.0025 ELSE 0 END
            )
        END AS DECIMAL(19,2)
    ) > 0