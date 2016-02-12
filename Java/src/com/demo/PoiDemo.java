package com.demo;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

import oracle.jdbc.OraclePreparedStatement;
import oracle.sql.NUMBER;

public class PoiDemo {

	public static void processFile(String apexUsername, NUMBER apexSessionId, NUMBER upload_file_id) throws Exception {
		Connection conn = DriverManager.getConnection("jdbc:default:connection:");

		String progress;

		// Log progress
		logStatus(upload_file_id, null, null, 1, "Started", 0, 0);

		try {
			Workbook workbook;
			PreparedStatement getFile = conn.prepareStatement("SELECT blob_content FROM wwv_flow_files WHERE id = ?");

			((OraclePreparedStatement) getFile).setNUMBER(1, upload_file_id);
			ResultSet rsFile = getFile.executeQuery();
	
			logStatus(upload_file_id, null, null, 1, "File opened", 0, 0);

			if (rsFile.next()) {
				workbook = WorkbookFactory.create(rsFile.getBlob(1).getBinaryStream());
			} else {
				throw new FileNotFoundException("File ID " + upload_file_id + " did not return any content.");
			}

			rsFile.close();
			getFile.close();
			Sheet sheet = workbook.getSheetAt(0);

			progress = "workbook created. Number of worksheets: " + workbook.getNumberOfSheets();
			logStatus(upload_file_id, null, null, 1, progress, sheet.getPhysicalNumberOfRows(), 0);

			if (sheet.getPhysicalNumberOfRows() == 0) {
				String errMsg = "Failure uploading file - No rows found in the first sheet of the document.";
				throw new PoiDemoException(errMsg);
			}

			// Load dept data directly to table
			Iterator<Row> rows = sheet.rowIterator();
			
			//Skip the first row, it just has header data
			rows.next();
			int ctr = 0;

			String dname, loc;
			Double deptno;
			while (rows.hasNext()) {
				ctr++;
				Row row = rows.next();

				if (row.getCell(0).getCellType() == Cell.CELL_TYPE_STRING && row.getCell(0).getStringCellValue().equals("")) {
					break;
				}

				deptno = row.getCell(0).getNumericCellValue();
				dname = row.getCell(1).getStringCellValue();
				loc = row.getCell(2).getStringCellValue();

				// Log progress
				progress = "Processing record. deptno: " + deptno + " dname: " + dname + " loc: " + loc;
				logStatus(upload_file_id, null, null, 2, progress, sheet.getPhysicalNumberOfRows(), ctr);

				insertDept(conn, new NUMBER(deptno), dname, loc);

			}

			// Load emp data into collection

			sheet = workbook.getSheetAt(1);
			// Log progress
			logStatus(upload_file_id, null, null, 2, "Emp sheet opened", sheet.getPhysicalNumberOfRows(), 0);

			if (sheet.getPhysicalNumberOfRows() == 0) {
				String errMsg = "Failure uploading file - No rows found in the first sheet of the document.";
				throw new PoiDemoException(errMsg);
			}
			
			rows = sheet.rowIterator();
			rows.next();
			ctr = 0;
			String ename, job, hiredate;
			Double empno, sal, comm, mgr;
			while (rows.hasNext()) {
				ctr++;
				Row row = rows.next();
				if (row.getCell(0).getCellType() == Cell.CELL_TYPE_STRING	&& row.getCell(0).getStringCellValue().equals("")) {
					break;
				}

				empno = row.getCell(0).getNumericCellValue();
				ename = row.getCell(1).getStringCellValue();
				job = row.getCell(2).getStringCellValue();	
				mgr = getDoubleOrNull(row.getCell(3));
				hiredate = row.getCell(4).getStringCellValue();
				sal = row.getCell(5).getNumericCellValue();
				comm = getDoubleOrNull(row.getCell(6));
				deptno = row.getCell(7).getNumericCellValue();

				// Log progress
				progress = "Processing record. empno: " + empno + " ename: " + ename + " job: " + job + " mgr: " + mgr
						+ " hiredate: " + hiredate + " sal: " + sal + " com: " + comm + " deptno: " + deptno;		
				logStatus(upload_file_id, null, null, 2, progress, sheet.getPhysicalNumberOfRows(), ctr);

				insertEmp(conn,apexUsername,  apexSessionId, empno, ename, job, mgr, hiredate, sal, comm, deptno, new NUMBER(ctr));
			}

		} catch (Exception ex) {
			logError(ex);
			Logger.getLogger(PoiDemo.class.getName()).log(Level.SEVERE, null, ex);
		} finally {
			conn.close();
		}
	}
	
	private static Double getDoubleOrNull(Cell readCell){
		Double returnVal;
		if (readCell.getCellType() == Cell.CELL_TYPE_BLANK
				|| readCell.getCellType() == Cell.CELL_TYPE_STRING) {
			returnVal = null;
		} else {
			returnVal = readCell.getNumericCellValue();
		}
		return returnVal;
	}

	private static void insertEmp(Connection conn,String apexUsername, NUMBER apexSessionId, Double empno, String ename, String job, Double mgr, String hiredate,
			Double sal, Double comm, Double deptno, NUMBER ctr) throws SQLException {
		DecimalFormat frmt =  new DecimalFormat("#");
		OraclePreparedStatement insEmp = (OraclePreparedStatement) conn.prepareStatement(
				" { call POI_DEMO.ADD_SPREEDSHEET_DATA_TO_COL(p_apex_username => ?, p_apex_session_id => ? ,p_C001 => ?,p_C002 => ?,p_C003 => ?,p_C004 => ?,p_C005 => ?,p_C006 => ?,p_C007 => ?,p_C008 => ?,p_n001 => ?)}");
		insEmp.setString(1, apexUsername);
		insEmp.setNUMBER(2, apexSessionId);		
		insEmp.setString(3, frmt.format(empno));
		insEmp.setString(4, ename);
		insEmp.setString(5, job);
		insEmp.setString(6, mgr == null ? "" : frmt.format(mgr));
		insEmp.setString(7, hiredate);
		insEmp.setString(8, sal == null ? "" : frmt.format(sal));
		insEmp.setString(9, comm == null ? "" : frmt.format(comm));
		insEmp.setString(10, frmt.format(deptno));
		insEmp.setNUMBER(11, ctr);
		insEmp.execute();
	}

	private static void insertDept(Connection conn, NUMBER deptno, String dname, String loc) throws SQLException {
		OraclePreparedStatement insDept = (OraclePreparedStatement) conn
				.prepareStatement(" INSERT INTO dept ( deptno, dname, loc ) VALUES ( ?, ?, ?)");
		insDept.setNUMBER(1, deptno);
		insDept.setString(2, dname);
		insDept.setString(3, loc);
		insDept.execute();
	}

	private static void logStatus(NUMBER upload_file_id, String file_path, String file_name, int status_id,
			String progress, int max_rows, int rows_processed) throws SQLException {
		Connection conn = DriverManager.getConnection("jdbc:default:connection:");

		OraclePreparedStatement insStatus = (OraclePreparedStatement) conn.prepareStatement(
				" INSERT INTO upload_status ( upload_file_id, file_path, file_name, status_id, progress, max_rows, rows_processed ) VALUES ( ?, ?, ?, ?, ?, ?, ? )");
		insStatus.setNUMBER(1, upload_file_id);
		insStatus.setString(2, file_path);
		insStatus.setString(3, file_name);
		insStatus.setNUMBER(4, new NUMBER(status_id));
		insStatus.setString(5, progress);
		insStatus.setNUMBER(6, new NUMBER(max_rows));
		insStatus.setNUMBER(7, new NUMBER(rows_processed));
		insStatus.execute();

	}

	private static void logError(Exception e) throws SQLException {
		Connection conn = DriverManager.getConnection("jdbc:default:connection:");
		try {
			CallableStatement emailError = conn.prepareCall(
					"{CALL error_pkg.send_error_email (p_error_type => error_pkg.poi_error_type, p_stacktrace => ?, p_module => 'PoiDemo')}");

			CallableStatement logError = conn.prepareCall(
					"{CALL error_pkg.log_error (p_error_type => error_pkg.poi_error_type, p_stacktrace => ?, p_module => 'PoiDemo')}");

			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			e.printStackTrace(pw);

			emailError.setString(1, sw.toString());
			emailError.execute();
			logError.setString(1, sw.toString());
			logError.execute();
		} catch (SQLException ex) {
			Logger.getLogger(PoiDemo.class.getName()).log(Level.SEVERE, null, ex);
		}
	}

}

class PoiDemoException extends Exception {
	private static final long serialVersionUID = -2162667999294275172L;

	public PoiDemoException(String errMsg) {
		super(errMsg);
	}

}
