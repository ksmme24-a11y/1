// Example user provisioning (Enterprise)
// Change passwords after initial login.

// read-only user
CREATE USER qa_reader IF NOT EXISTS SET PASSWORD 'ChangeMe1!' CHANGE NOT REQUIRED;
GRANT ROLE reader TO qa_reader;

// data publisher (read+write)
CREATE USER qa_publisher IF NOT EXISTS SET PASSWORD 'ChangeMe2!' CHANGE NOT REQUIRED;
GRANT ROLE publisher TO qa_publisher;

// schema architect (create indexes/constraints)
CREATE USER qa_arch IF NOT EXISTS SET PASSWORD 'ChangeMe3!' CHANGE NOT REQUIRED;
GRANT ROLE architect TO qa_arch;

