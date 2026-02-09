import sys
import oracledb
# This forces oracledb to act as cx_Oracle for SQLAlchemy 1.4
oracledb.version = "8.3.0"
sys.modules["cx_Oracle"] = oracledb
