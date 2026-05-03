import pymysql

def get_db_connection():
    # Kết nối trực tiếp đến MySQL Workbench
    connection = pymysql.connect(
        host='localhost',
        user='root',
        password='123456',
        database='todoapp',
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection