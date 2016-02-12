CREATE OR REPLACE PACKAGE error_pkg
AS
   poi_error_type      CONSTANT INTEGER := 1;

   PROCEDURE log_error (p_error_type INTEGER, p_stacktrace VARCHAR2, p_module VARCHAR2);

   PROCEDURE log_error (p_error_type        INTEGER
                       ,p_stacktrace        VARCHAR2
                       ,p_module            VARCHAR2
                       ,p_errorlog_id   OUT error_log.error_log_id%TYPE);

   PROCEDURE log_error_and_send_email (p_error_type INTEGER, p_stacktrace VARCHAR2, p_module VARCHAR2);

   PROCEDURE send_error_email (p_error_type INTEGER, p_stacktrace VARCHAR2, p_module VARCHAR2);
END error_pkg;
/
CREATE OR REPLACE PACKAGE BODY error_pkg
AS
   PROCEDURE log_error (p_error_type INTEGER, p_stacktrace VARCHAR2, p_module VARCHAR2)
   AS
      l_error_id   error_log.error_log_id%TYPE;
   BEGIN
      log_error (p_error_type    => p_error_type
                ,p_stacktrace    => p_stacktrace
                ,p_module        => p_module
                ,p_errorlog_id   => l_error_id);                                        -- don't care about the error ID
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END log_error;

   PROCEDURE log_error_and_send_email (p_error_type INTEGER, p_stacktrace VARCHAR2, p_module VARCHAR2)
   AS
   BEGIN
      error_pkg.send_error_email (p_error_type   => p_error_type
                                 ,p_stacktrace   => p_stacktrace
                                 ,p_module       => p_module);
      error_pkg.log_error (p_error_type   => p_error_type
                          ,p_stacktrace   => p_stacktrace
                          ,p_module       => p_module);
   END log_error_and_send_email;



   PROCEDURE log_error (p_error_type        INTEGER
                       ,p_stacktrace        VARCHAR2
                       ,p_module            VARCHAR2
                       ,p_errorlog_id   OUT error_log.error_log_id%TYPE)
   AS
      l_error_type   VARCHAR2 (20);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      CASE p_error_type
         WHEN poi_error_type
         THEN
            l_error_type := 'poi_error_type';
         ELSE
            l_error_type := 'poi_error_type';
      END CASE;

      INSERT INTO error_log (stacktrace, module, ERROR_TYPE)
           VALUES (p_stacktrace, p_module, l_error_type)
        RETURNING error_log_id
             INTO p_errorlog_id;

      COMMIT;
   --We can't allow calls to this to fail
   --Since this is how we log errors, if it fails
   --There is nothing we can do about it
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END log_error;

   PROCEDURE send_error_email (p_error_type INTEGER, p_stacktrace VARCHAR2, p_module VARCHAR2)
   AS
      l_to           VARCHAR2 (500);
      l_from         VARCHAR2 (100) := 'thomas.sheffer@gmail.com';
      l_body         VARCHAR2 (4000);
      l_subj         VARCHAR2 (1000);
      l_module       VARCHAR2 (100) := 'send_error_email';
      l_stacktrace   VARCHAR2 (2000);
      l_error_type   INTEGER := error_pkg.poi_error_type;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      --set security group id in order to be able to call
      --apex_mail
      APEX_UTIL.set_security_group_id (p_security_group_id => '2224912942262033');

      --Get email address to send email to
            l_to := 'thomas.sheffer@gmail.com'; 

      l_subj := l_subj || 'An error has occurred during: ' || p_module || ' - ' || SYS_CONTEXT ('USERENV', 'DB_NAME');
      l_body := p_stacktrace;
      --send the error
      apex_mail.send (p_to          => l_to
                     ,p_from        => l_from
                     ,p_body        => l_body
                     ,p_body_html   => l_body
                     ,p_subj        => l_subj);

      --We dont care if this fails
      BEGIN
         apex_mail.push_queue;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_stacktrace := DBMS_UTILITY.format_error_stack || DBMS_UTILITY.format_error_backtrace;
         error_pkg.log_error (p_error_type => l_error_type, p_stacktrace => l_stacktrace, p_module => l_module);
   END send_error_email;
END error_pkg;
/
