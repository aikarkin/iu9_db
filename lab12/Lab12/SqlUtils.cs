using System;
using System.Configuration;
using System.Data.Common;
using System.Data.SqlClient;
using System.IO;

namespace Lab12
{
    class SqlUtils : IDisposable
    {
        private DbConnection conn;
        private DbProviderFactory df;
        private ConnectionStringSettings connStr;

        public SqlUtils()
        {
            try { 
                this.connStr = ConfigurationManager.ConnectionStrings["linuxMsSqlServer"];
                this.df = DbProviderFactories.GetFactory(this.connStr.ProviderName);
            } catch(ConfigurationErrorsException ce)
            {
                Console.WriteLine("#ERROR: Unnable to read configuration");
                Console.WriteLine("#Couse: " + ce.BareMessage);
            }
        }

        public void Dispose()
        {
            if (conn != null)
            {
                this.conn.Close();
            }
        }

        public DbConnection Connection
        {
            get
            {
                if (connStr != null && connStr.ConnectionString != null && conn == null)
                {
                    try
                    {
                        conn = df.CreateConnection();
                        conn.ConnectionString = connStr.ConnectionString;
                        conn.Open();
                    } catch(InvalidOperationException ioe) 
                    {
                        Console.WriteLine("#ERROR: Unnable to open connection. Data source is not specified or connections is already opened");
                        Console.WriteLine("##ERROR MESSAGE: " + ioe.Message);
                    } catch(System.Data.SqlClient.SqlException se) 
                    {
                        Console.WriteLine("#ERROR: Connection error");
                        Console.WriteLine("#ERROR MESSAGE: " + se.Message);
                    }
                }
                return conn;
            }
        }

        public void PrintSelect(string tableName, string[] columnNames)
        {
            try
            {
                string query = $"SELECT {String.Join(", ", columnNames)} FROM {tableName}";
                Console.WriteLine($"#INFO: execute query \"{query}\"");
                DbCommand selectCmd = df.CreateCommand();
                selectCmd.Connection = Connection;
                selectCmd.CommandText = query;

                DbDataReader dbReader = selectCmd.ExecuteReader();

                for (int i = 0; i < dbReader.FieldCount; i++)
                {
                    Console.Write($"{dbReader.GetName(i),20}");
                }

                Console.WriteLine();
                Console.WriteLine(new String('_', 60));

                while (dbReader.Read())
                {
                    for (int i = 0; i < dbReader.FieldCount; i++)
                    {
                        Console.Write($"{dbReader[i],20}");
                    }
                    Console.WriteLine();
                }

                Console.WriteLine(new String('_', 60));

                dbReader.Close();
            } catch (SqlException sqlEx)
            {
                Console.WriteLine("#ERROR: An error occured while executing select: ");
                Console.WriteLine("#ERROR MESSAGE: " + sqlEx.Message);
            } 
        }


        private void ExecudeNonQuery(string query)
        {
            try
            {
                Console.WriteLine("#INFO: execute query \"{0}\"", query);
                DbCommand cmd = df.CreateCommand();
                cmd.CommandText = query;
                cmd.Connection = Connection;
                Console.WriteLine("#INFO: {0} record(s) affected", cmd.ExecuteNonQuery());
            } catch(SqlException se)
            {
                Console.WriteLine("#ERROR: Unnable to execute non-query command." );
                Console.WriteLine("#ERROR MESSAGE: " + se.Message);
            } catch(IOException ioEx)
            {
                Console.WriteLine("#ERROR: Unnable to execute non-query command. An error can be occured while data transferred");
                Console.WriteLine("#ERROR MESSAGE: " + ioEx.Message);
            }
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
