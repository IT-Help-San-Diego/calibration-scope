-- Migration 053: defeasible class answer tokens VALID/INVALID -> HOLDS/DEFEATED.
-- Claude Science SECOND_READ_11_keys §2: VALID encodes a classical reading the stem
-- does not enforce (LOGIC-03N pattern). HOLDS=default inference licensed, DEFEATED=not.
UPDATE tests
SET prompt_text = REPLACE(REPLACE(prompt_text,
    'Answer with exactly one word: VALID or INVALID.',
    'Answer with exactly one word: HOLDS or DEFEATED.'),
    'VALID or INVALID', 'HOLDS or DEFEATED'),
    expected_result = CASE expected_result WHEN 'VALID' THEN 'HOLDS' WHEN 'INVALID' THEN 'DEFEATED' ELSE expected_result END
WHERE name LIKE 'PROBE-C2%' AND active=true;
