alter VIEW "AXIS"."ECSB1_PFGMonthlyAPPosting" ( "CardCode",
	 "Member Name",
	 "Rebate Type",
	 "AcctCode",
	 "Rebate Description",
	 "Account",
	 "Rebate Amount" ) AS SELECT
	 a."CardCode",
	 a."Member Name",
	 --a."Net Sales",
 r."Rebate Type",
	 r."AcctCode",
	 CASE r."Rebate Type" when 'Rebate-01' 
then '2.25% PFG / AFFLINK Rebate' when 'Rebate-02' 
then '.5% PFG Growth Rebate' when 'Rebate-03' 
then '3% PFG Corporate Rebate' when 'Rebate-04' 
then '4% PFG Specilists Rebate' when 'Rebate-05' 
then '.25% PFG Show Allowance - Disposables' when 'Rebate-06' 
then '.25% PFG Show Allowance - E&S' 
end "Rebate Description",
	 coa."Segment_0" || '-' || coa."Segment_1" || '-' || coa."Segment_2" || '-' || coa."Segment_3" as "Account",
	 CAST( CASE r."Rebate Type" -- 23200001-01-001-01 - Accrued Expense PFG / AFFLINK Rebate 2.25% (2% PFG, .25% AFFLINK) C03282 Disposables & C03283 E&S
 WHEN 'Rebate-01' 
	THEN sum(a."Net Sales") * 0.0225 -- 23200002-01-001-01 - Accrued Expenses PFG Growth Rebate .5% C03282 Disposables & C03283 E&S
 WHEN 'Rebate-02' 
	THEN sum(a."Net Sales") * 0.005 -- 23200003-01-001-01 - Accrued Expenses PFG Corporate Rebate 3.00%
 WHEN 'Rebate-03' 
	THEN sum(a."Net Sales") * (CASE WHEN a."CardCode" IN ('C03361',
	 'C03362',
	 'C03364') 
		THEN 0.03 
		ELSE 0 
		END) -- 23200004-01-001-01 - Accrued Expenses PFG Specilists Rebate 4.00%
 WHEN 'Rebate-04' 
	THEN sum(a."Net Sales") * (CASE WHEN a."CardCode" IN ('C03361',
	 'C03362',
	 'C03364') 
		THEN 0.04 
		ELSE 0 
		END) -- 23200005-01-001-01 - Accrued Expense .25% PFG Show Allowance - Disposables
 WHEN 'Rebate-05' 
	THEN sum(a."Net Sales") * (CASE WHEN a."CardCode" IN ('C03282',
	 'C03283') --Cheney Only
 
		THEN 0.0025 
		ELSE 0 
		END) -- 23200006-01-001-01 - Accrued Expense .25% PFG Show Allowance - E&S
 WHEN 'Rebate-06' 
	THEN sum(a."Net Sales") * (CASE WHEN a."CardCode" IN ('C03282',
	 'C03283') --Cheney Only
 
		THEN 0.0025 
		ELSE 0 
		END) 
	END AS DECIMAL(19,
	 2) ) AS "Rebate Amount" 
FROM ( SELECT
	 t2."CardCode",
	 t2."CardName" AS "Member Name",
	 sum(t1."LineTotal") AS "Net Sales" 
	FROM "OINV" t0 
	INNER JOIN "INV1" t1 ON t0."DocEntry" = t1."DocEntry" 
	INNER JOIN "OCRD" t2 ON t0."CardCode" = t2."CardCode" 
	WHERE t0."CANCELED" = 'N' 
	AND t0."DocType" = 'I'
	AND t2."GroupCode" = 130 
	and month(T0."DocDate") = month(current_date) 
	and year(T0."DocDate") = year(current_date) /* 
	AND t0."DocDate" >= ADD_DAYS(LAST_DAY(ADD_MONTHS(CURRENT_DATE,
	 -2)),
	 +1) 
	AND t0."DocDate" <= LAST_DAY(ADD_MONTHS(CURRENT_DATE,
	 -1)) */ 
	GROUP BY t2."CardCode",
	 t2."CardName" 
	UNION ALL SELECT
	 t2."CardCode",
	 t2."CardName" AS "Member Name",
	 sum(-t1."LineTotal") AS "Net Sales" 
	FROM "ORIN" t0 
	INNER JOIN "RIN1" t1 ON t0."DocEntry" = t1."DocEntry" 
	INNER JOIN "OCRD" t2 ON t0."CardCode" = t2."CardCode" 
	WHERE t0."CANCELED" = 'N' 
	AND t0."DocType" = 'I'
	AND t2."GroupCode" = 130 
	and month(T0."DocDate") = month(current_date) 
	and year(T0."DocDate") = year(current_date) /* 
	AND t0."DocDate" >= ADD_DAYS(LAST_DAY(ADD_MONTHS(CURRENT_DATE,
	 -2)),
	 +1) 
	AND t0."DocDate" <= LAST_DAY(ADD_MONTHS(CURRENT_DATE,
	 -1)) */ 
	GROUP BY t2."CardCode",
	 t2."CardName" ) a CROSS JOIN ( SELECT
	 'Rebate-01' AS "Rebate Type",
	 '_SYS00000000373' as "AcctCode" 
	FROM DUMMY 
	UNION ALL SELECT
	 'Rebate-02',
	 '_SYS00000000374' 
	FROM DUMMY 
	UNION ALL SELECT
	 'Rebate-03',
	 '_SYS00000000402' 
	FROM DUMMY 
	UNION ALL SELECT
	 'Rebate-04',
	 '_SYS00000000403' 
	FROM DUMMY 
	UNION ALL SELECT
	 'Rebate-05',
	 '_SYS00000000404' 
	FROM DUMMY 
	UNION ALL SELECT
	 'Rebate-06',
	 '_SYS00000000405' 
	FROM DUMMY ) r 
inner join OACT coa on r."AcctCode" = coa."AcctCode" 
GROUP BY a."CardCode",
	 a."Member Name",
	 r."Rebate Type",
	 r."AcctCode",
	 coa."AcctName",
	 coa."Segment_0" || '-' || coa."Segment_1" || '-' || coa."Segment_2" || '-' || coa."Segment_3" HAVING CAST( CASE r."Rebate Type" -- 23200001-01-001-01 - Accrued Expense PFG / AFFLINK Rebate 2.25% (2% PFG, .25% AFFLINK) C03282 Disposables & C03283 E&S
 WHEN 'Rebate-01' 
	THEN sum(a."Net Sales") * 0.0225 -- 23200002-01-001-01 - Accrues Expenses PFG Growth Rebate .5% C03282 Disposables & C03283 E&S
 WHEN 'Rebate-02' 
	THEN sum(a."Net Sales") * 0.005 -- 23200003-01-001-01 - Accrued Expenses PFG Corporate Rebate 3.00%
 WHEN 'Rebate-03' 
	THEN sum(a."Net Sales") * (CASE WHEN a."CardCode" IN ('C03361',
	 'C03362',
	 'C03364') 
		THEN 0.03 
		ELSE 0 
		END) -- 23200004-01-001-01 - Accrued Expenses PFG Specilists Rebate 4.00%
 WHEN 'Rebate-04' 
	THEN sum(a."Net Sales") * (CASE WHEN a."CardCode" IN ('C03361',
	 'C03362',
	 'C03364') 
		THEN 0.04 
		ELSE 0 
		END) -- 23200005-01-001-01 - Accrued Expense .25% PFG Show Allowance - Disposables
 WHEN 'Rebate-05' 
	THEN sum(a."Net Sales") * (CASE WHEN a."CardCode" IN ('C03282',
	 'C03283') --Cheney Only
 
		THEN 0.0025 
		ELSE 0 
		END) -- 23200006-01-001-01 - Accrued Expense .25% PFG Show Allowance - E&S
 WHEN 'Rebate-06' 
	THEN sum(a."Net Sales") * (CASE WHEN a."CardCode" IN ('C03282',
	 'C03283') --Cheney Only
 
		THEN 0.0025 
		ELSE 0 
		END) 
	END AS DECIMAL(19,
	 2) ) > 0 