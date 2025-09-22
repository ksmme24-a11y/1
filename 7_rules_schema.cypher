// Rule 스키마 및 인덱스/제약

CREATE CONSTRAINT c_rule IF NOT EXISTS
FOR (n:Rule) REQUIRE n.name IS UNIQUE;

CREATE INDEX i_rule_regex IF NOT EXISTS FOR (n:Rule) ON (n.regex);
CREATE INDEX i_rule_priority IF NOT EXISTS FOR (n:Rule) ON (n.priority);
CREATE INDEX i_rule_confidence IF NOT EXISTS FOR (n:Rule) ON (n.confidence);

