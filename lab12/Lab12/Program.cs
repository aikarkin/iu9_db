using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Lab12
{
    class Program
    {
        static void Main(string[] args)
        {
            SqlUtils utils = new SqlUtils();

            // inconsistent data model
            //utils.PrintSelect("[User]", new string[] { "Email", "UserName" });
            //Console.WriteLine();

            //utils.ExecuteDelete("[User]");
            //Console.WriteLine();

            //utils.PrintSelect("[User]", new string[] { "Email", "UserName" });
            //Console.WriteLine();

            //utils.ExecuteInsert("[User]", new string[] { "Email", "UserName" }, new string[] { "N'person2@example.com'", "N'person2'" });
            //utils.ExecuteInsert("[User]", new string[] { "Email", "UserName" }, new string[] { "N'person3@example.com'", "N'person3'" });
            //Console.WriteLine();

            //utils.PrintSelect("[User]", new string[] { "Email", "UserName", "About" });
            //Console.WriteLine();

            //utils.ExecuteUpdate("[User]", new string[] { "About" }, new string[] { "N'student'" }, "UserName LIKE 'person%'");
            //Console.WriteLine();

            //utils.PrintSelect("[User]", new string[] { "Email", "UserName", "About" });

            // consistent data model
            SqlConnection sqlConn = (SqlConnection)utils.Connection;

            SqlDataAdapter userAdapter = new SqlDataAdapter("SELECT * FROM dbo.[User];", sqlConn);
            SqlDataAdapter filmAdapter = new SqlDataAdapter("SELECT * FROM dbo.[Film];", sqlConn);

            DataSet dataSet = new DataSet();

            userAdapter.Fill(dataSet, "User");
            filmAdapter.Fill(dataSet, "Film");

            // print tables' content
            foreach (DataTable table in dataSet.Tables)
            {
                Console.WriteLine(table.TableName + ": ");

                List<object> items = new List<object>();
                foreach (DataRow row in table.Rows)
                {
                    List<string> values = new List<string>();
                    foreach (var value in row.ItemArray)
                    {
                        values.Add(value.ToString());
                    }
                    items.Add($"{{ {String.Join(", ", values)} }}");
                }

                Console.WriteLine(String.Join(",\n", items) + "\n");
            }

            // insert row
            Console.WriteLine("Row states: ");
            DataTable users = dataSet.Tables["User"];

            DataRow nRow = users.NewRow();
            Console.WriteLine(nRow.RowState);

            users.Rows.Add(nRow);
            Console.WriteLine(nRow.RowState);

            users.AcceptChanges();
            Console.WriteLine(nRow.RowState);

            nRow["UserName"] = "alex";
            Console.WriteLine(nRow.RowState);

            // remove row
            nRow.Delete();
            Console.WriteLine(nRow.RowState);
        }
    }
}
