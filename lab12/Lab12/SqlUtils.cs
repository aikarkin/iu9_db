using System;
using System.Configuration;
using System.Data.Common;


namespace Lab12
{
    class SqlUtils : IDisposable
    {
        private DbConnection conn;
        private DbProviderFactory df;
        private ConnectionStringSettings connStr;

        public SqlUtils()
        {
            this.connStr = ConfigurationManager.ConnectionStrings["linuxMsSqlServer"];
            this.df = DbProviderFactories.GetFactory(this.connStr.ProviderName);
        }

        public void Dispose()
        {
            this.conn.Close();
        }

        public DbConnection Connection
        {
            get
            {
                if (conn == null)
                {
                    conn = df.CreateConnection();
                    conn.ConnectionString = connStr.ConnectionString;
                    conn.Open();
                }
                return conn;
            }
        }

        public void PrintSelect(string tableName, string[] columnNames)
        {
            string query = $"SELECT {String.Join(", ", columnNames)} FROM {tableName}";
            Console.WriteLine($"#INFO: execute query \"{query}\"");
            DbCommand selectCmd = df.CreateCommand();
            selectCmd.Connection = Connection;
            selectCmd.CommandText = query;

            DbDataReader dbReader = selectCmd.ExecuteReader();

            for (int i = 0; i < dbReader.FieldCount; i++)
            {
                Console.Write($"{dbReader.GetName(i), 20}");
            }

            Console.WriteLine();
            Console.WriteLine(new String('_', 60));

            while (dbReader.Read())
            {
                for (int i = 0; i < dbReader.FieldCount; i++)
                {
                    Console.Write($"{dbReader[i], 20}");
                }
                Console.WriteLine();
            }

            Console.WriteLine(new String('_', 60));

            dbReader.Close();
        }


        private void ExecudeNonQuery(string query)
        {
            Console.WriteLine("#INFO: execute query \"{0}\"", query);
            DbCommand cmd = df.CreateCommand();
            cmd.CommandText = query;
            cmd.Connection = Connection;
            Console.WriteLine("#INFO: {0} record(s) affected", cmd.ExecuteNonQuery());
        }

        public void ExecuteDelete(string tableName, string condition=null)
        {
            string conditionStmnt = condition != null ? "WHERE" + condition : "";
            ExecudeNonQuery($"DELETE FROM {tableName} {conditionStmnt}");   
        }

        public void ExecuteInsert(string tableName, string[] columns, string[] values)
        {
            ExecudeNonQuery($"INSERT INTO {tableName} ({String.Join(", ", columns)}) VALUES ({String.Join(", ", values)})");
        }

        public void ExecuteUpdate(string tableName, string[] columns, string[] values, string condition=null)
        {
            string[] setStatements = new string[columns.Length];

            for (int i = 0; i < columns.Length; i++)
            {
                setStatements[i] = $"{columns[i]}={values[i]}";
            }
            string conditionStmnt = (condition == null) ? "" : $"WHERE {condition}";
            ExecudeNonQuery($"UPDATE {tableName} SET {String.Join(", ", setStatements)} {conditionStmnt}");
        }
    }
    
}
