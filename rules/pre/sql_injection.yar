/*
 * SQL Injection Detection Rule
 * 
 * This rule detects various SQL injection attack patterns including:
 * - SQL keywords and operators
 * - Comment patterns for SQL injection
 * - Union-based injection patterns
 * - Boolean-based injection patterns
 * - Time-based injection patterns
 * - Error-based injection patterns
 * - Stacked queries
 * - Evasion techniques (encoding, obfuscation)
 * - Database-specific injection patterns
 * - ORM bypass techniques
 * 
 * Designed to detect SQL injection in tool descriptions while avoiding
 * false positives on legitimate database-related tool names
 */

rule SQLInjection
{
    meta:
        name = "Advanced SQL Injection Detection"
        author = "Ramparts Security Team"
        date = "2024-12-19"
        version = "1.0"
        description = "Comprehensive SQL injection detection covering multiple attack vectors and evasion techniques"
        severity = "CRITICAL"
        category = "sql-injection,security,database,web-security,data-exfiltration,authentication-bypass"
        confidence = "HIGH"
        
    strings:
        // SQL Keywords and Operators (more specific patterns)
        $sql_keywords = /\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|EXECUTE|UNION|OR|AND|WHERE|FROM|HAVING|GROUP BY|ORDER BY|LIMIT|OFFSET)\b/i
        
        // SQL Comment Patterns
        $sql_comments = /(--|#|\/\*|\*\/|;--|;#|;\/\*|;\*\/)/
        $inline_comments = /(--\s*$|#\s*$|\/\*\s*$|\*\/\s*$)/
        
        // Union-based Injection Patterns
        $union_injection = /\b(UNION\s+ALL\s+SELECT|UNION\s+SELECT|UNION\s+ALL|UNION\s+SELECT\s+NULL|UNION\s+SELECT\s+1|UNION\s+SELECT\s+1,2|UNION\s+SELECT\s+1,2,3)\b/i
        $union_columns = /\b(UNION\s+SELECT\s+[^;]+FROM|UNION\s+SELECT\s+[^;]+WHERE|UNION\s+SELECT\s+[^;]+GROUP BY)\b/i
        
        // Boolean-based Injection Patterns
        $boolean_injection = /\b(OR\s+1=1|OR\s+'1'='1'|OR\s+TRUE|AND\s+1=1|AND\s+'1'='1'|AND\s+TRUE|OR\s+1|AND\s+1)\b/i
        $boolean_operators = /\b(OR\s+[0-9]+=[0-9]+|AND\s+[0-9]+=[0-9]+|OR\s+[a-zA-Z]+=[a-zA-Z]+|AND\s+[a-zA-Z]+=[a-zA-Z]+)\b/i
        
        // Time-based Injection Patterns
        $time_injection = /\b(SLEEP\s*\(|BENCHMARK\s*\(|WAITFOR\s+DELAY|PG_SLEEP\s*\(|DBMS_PIPE\.RECEIVE_MESSAGE)\b/i
        $delay_patterns = /\b(SLEEP\s*\([0-9]+\)|BENCHMARK\s*\([0-9]+|WAITFOR\s+DELAY\s+'[0-9:]+'|PG_SLEEP\s*\([0-9]+\))\b/i
        
        // Error-based Injection Patterns
        $error_injection = /\b(AND\s+UPDATEXML|AND\s+EXTRACTVALUE|AND\s+FLOOR|AND\s+CONVERT|AND\s+CAST|AND\s+CONCAT)\b/i
        $error_functions = /\b(UPDATEXML\s*\(|EXTRACTVALUE\s*\(|FLOOR\s*\(|CONVERT\s*\(|CAST\s*\(|CONCAT\s*\()\b/i
        
        // Stacked Queries
        $stacked_queries = /(;\s*SELECT|;\s*INSERT|;\s*UPDATE|;\s*DELETE|;\s*DROP|;\s*CREATE|;\s*ALTER|;\s*EXEC|;\s*EXECUTE)\b/i
        $multiple_statements = /(SELECT\s+.*;\s*SELECT|INSERT\s+.*;\s*SELECT|UPDATE\s+.*;\s*SELECT|DELETE\s+.*;\s*SELECT)\b/i
        
        // Database-specific Injection Patterns
        $mysql_injection = /\b(INFORMATION_SCHEMA|mysql\.|@@version|@@hostname|@@datadir|@@basedir|@@tmpdir|@@slave_load_tmpdir)\b/i
        $postgresql_injection = /\b(pg_catalog|information_schema|current_database|current_user|session_user|version|pg_stat_activity)\b/i
        $mssql_injection = /\b(sys\.|sysobjects|syscolumns|sysdatabases|@@version|@@servername|@@language|@@spid)\b/i
        $oracle_injection = /\b(ALL_TABLES|ALL_USERS|ALL_INDEXES|ALL_CONSTRAINTS|USER_TABLES|USER_USERS|V\$|DBA_)\b/i
        
        // Evasion Techniques
        $encoding_evasion = /(%27|%22|%3B|%2D%2D|%23|%2F%2A|%2A%2F|%3C%3E|%3D|%3C|%3E)/i
        $hex_encoding = /(0x[0-9a-fA-F]+|\\x[0-9a-fA-F]+|\\u[0-9a-fA-F]{4})/i
        $unicode_encoding = /(\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8})/i
        $case_variation = /([Ss][Ee][Ll][Ee][Cc][Tt]|[Ii][Nn][Ss][Ee][Rr][Tt]|[Uu][Pp][Dd][Aa][Tt][Ee]|[Dd][Ee][Ll][Ee][Tt][Ee])/i
        
        // ORM Bypass Techniques
        $orm_bypass = /\b(OR\s+1\s*=\s*1|AND\s+1\s*=\s*1|OR\s+TRUE|AND\s+TRUE|OR\s+'1'\s*=\s*'1'|AND\s+'1'\s*=\s*'1')\b/i
        $parameter_bypass = /\b(OR\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*[a-zA-Z_][a-zA-Z0-9_]*|AND\s+[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*[a-zA-Z_][a-zA-Z0-9_]*)\b/i
        
        // Authentication Bypass Patterns
        $auth_bypass = /\b(OR\s+1\s*=\s*1\s*--|OR\s+'1'\s*=\s*'1'\s*--|OR\s+TRUE\s*--|AND\s+1\s*=\s*1\s*--|AND\s+'1'\s*=\s*'1'\s*--)\b/i
        $login_bypass = /\b(admin'--|admin'#|admin'\/\*|' OR '1'='1|' OR 1=1|' OR TRUE|' AND '1'='1|' AND 1=1)\b/i
        
        // Data Exfiltration Patterns
        $data_exfil = /\b(SELECT\s+.*FROM\s+.*WHERE|SELECT\s+.*FROM\s+.*LIMIT|SELECT\s+.*FROM\s+.*OFFSET)\b/i
        $sensitive_data = /\b(SELECT\s+.*password|SELECT\s+.*passwd|SELECT\s+.*secret|SELECT\s+.*key|SELECT\s+.*token|SELECT\s+.*credential)\b/i
        
        // Blind SQL Injection Patterns
        $blind_injection = /\b(AND\s+1\s*=\s*1|AND\s+'1'\s*=\s*'1'|AND\s+TRUE|OR\s+1\s*=\s*1|OR\s+'1'\s*=\s*'1'|OR\s+TRUE)\b/i
        $conditional_logic = /\b(IF\s*\(|CASE\s+WHEN|WHEN\s+.*\s+THEN|ELSE|END\s+IF|END\s+CASE)\b/i
        
        // Legitimate patterns to exclude (avoid false positives)
        $legitimate_patterns = /(database_tool|sql_client|query_builder|orm_tool|migration_tool|backup_tool|replication_tool|monitoring_tool|analytics_tool|reporting_tool)/
        $safe_keywords = /(SELECT\s+tool|INSERT\s+tool|UPDATE\s+tool|DELETE\s+tool|CREATE\s+tool|ALTER\s+tool)/
        
    condition:
        // Primary detection: SQL keywords with injection patterns
        ($sql_keywords and ($sql_comments or $union_injection or $boolean_injection or $time_injection)) or
        
        // Union-based injection
        $union_injection or
        $union_columns or
        
        // Boolean-based injection
        ($boolean_injection and not $legitimate_patterns) or
        ($boolean_operators and not $legitimate_patterns) or
        
        // Time-based injection
        $time_injection or
        $delay_patterns or
        
        // Error-based injection
        $error_injection or
        $error_functions or
        
        // Stacked queries
        $stacked_queries or
        $multiple_statements or
        
        // Database-specific injection
        ($mysql_injection and $sql_keywords) or
        ($postgresql_injection and $sql_keywords) or
        ($mssql_injection and $sql_keywords) or
        ($oracle_injection and $sql_keywords) or
        
        // Evasion techniques
        ($encoding_evasion and $sql_keywords) or
        ($hex_encoding and $sql_keywords) or
        ($unicode_encoding and $sql_keywords) or
        ($case_variation and $sql_keywords) or
        
        // ORM bypass
        ($orm_bypass and not $legitimate_patterns) or
        ($parameter_bypass and not $legitimate_patterns) or
        
        // Authentication bypass
        $auth_bypass or
        $login_bypass or
        
        // Data exfiltration
        ($data_exfil and not $safe_keywords) or
        $sensitive_data or
        
        // Blind SQL injection
        ($blind_injection and not $legitimate_patterns) or
        ($conditional_logic and $sql_keywords) or
        
        // SQL comments with keywords
        ($sql_comments and $sql_keywords) or
        ($inline_comments and $sql_keywords)
} 