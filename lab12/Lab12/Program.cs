using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Lab12
{
    class Program
    {
        static void PrintTable(DataTable table) {
            Console.WriteLine($"{table.TableName} (consistent)");
            Console.WriteLine(new String('_', 80));

            foreach (DataRow row in table.Rows)
            {
                foreach (var value in row.ItemArray)
                {
                    string valStr = value.ToString();
                    Console.Write($"{valStr},\t");
                }
                Console.WriteLine();
            }

            Console.WriteLine(new String('_', 80));

        }

        static void Main(string[] args)
        {
            SqlUtils utils;
            try
            {
                utils = new SqlUtils();

                // connected layer
                Console.WriteLine("Inconsistent data model");

                utils.PrintSelect("[User]", new string[] { "Email", "UserName" });
                Console.WriteLine();

                utils.ExecuteDelete("[User]");
                Console.WriteLine();

                utils.PrintSelect("[User]", new string[] { "Email", "UserName" });
                Console.WriteLine();

                utils.ExecuteInsert("[User]", new string[] { "Email", "UserName" }, new string[] { "N'person1@example.com'", "N'person1'" });
                utils.ExecuteInsert("[User]", new string[] { "Email", "UserName" }, new string[] { "N'person2@example.ru'", "N'person2'" });
                utils.ExecuteInsert("[User]", new string[] { "Email", "UserName" }, new string[] { "N'person3@example.com'", "N'person3'" });
                utils.ExecuteInsert("[User]", new string[] { "Email", "UserName" }, new string[] { "N'person4@example.ru'", "N'person4'" });
                Console.WriteLine();

                utils.PrintSelect("[User]", new string[] { "Email", "UserName", "About" });
                Console.WriteLine();

                utils.ExecuteUpdate("[User]", new string[] { "About" }, new string[] { "N'student'" }, "UserName LIKE 'person%'");
                Console.WriteLine();

                utils.PrintSelect("[User]", new string[] { "Email", "UserName", "About" });


                // disconnected layer
                Console.WriteLine(new String('#', 30));
                Console.WriteLine("Consistent data model");

                SqlConnection sqlConn = (SqlConnection)utils.Connection;

                SqlDataAdapter userAdapter = new SqlDataAdapter("SELECT * FROM dbo.[User];", sqlConn);
                DataSet dataSet = new DataSet();

                //SqlCommand usrIns = new SqlCommand("INSERT INTO [User] (Email, UserName) VALUES (@Email, @UserName)", sqlConn);
                SqlCommand usrIns = new SqlCommand("dbo.InsertUser", sqlConn);
                usrIns.CommandType = CommandType.StoredProcedure;
                SqlCommand usrUpd = new SqlCommand("UPDATE [User] SET Email=@Email, UserName=@UserName, About=@About WHERE UserId=@UserId", sqlConn);
                SqlCommand usrDel = new SqlCommand("DELETE FROM [User] WHERE UserId=@UserId", sqlConn);

                usrUpd.Parameters.Add("@Email", SqlDbType.NVarChar, 120, "Email");
                usrUpd.Parameters.Add("@UserName", SqlDbType.NVarChar, 120, "UserName");
                usrUpd.Parameters.Add("@About", SqlDbType.Text, 0, "About");
                usrUpd.Parameters.Add("@UserId", SqlDbType.Int, 120, "UserId");

                SqlParameter emailParam = usrIns.Parameters.Add("@email", SqlDbType.NVarChar, 120, "Email");
                SqlParameter nameParam = usrIns.Parameters.Add("@name", SqlDbType.NVarChar, 120, "UserName");
                SqlParameter outIdParam = usrIns.Parameters.Add("@out_id", SqlDbType.Int, 0, "UserId");

                emailParam.Direction = ParameterDirection.Input;
                nameParam.Direction = ParameterDirection.Input;
                outIdParam.Direction = ParameterDirection.Output;

                usrDel.Parameters.Add("@UserId", SqlDbType.Int, 0, "UserId");

                userAdapter.InsertCommand = usrIns;
                userAdapter.UpdateCommand = usrUpd;
                userAdapter.DeleteCommand = usrDel;

                    userAdapter.Fill(dataSet, "User");
                    DataTable users = dataSet.Tables["User"];

                    // print table content 
                    PrintTable(users);

                    // modify rows
                    foreach (DataRow ur in users.Rows)
                    {
                        string name = (String)ur["UserName"];
                        if (name.Contains("person"))
                        {
                            ur["About"] = "employee";
                        }
                    }

                    Console.WriteLine("#INFO: Users after modify:");
                    PrintTable(users);

                    // del row

                    Console.WriteLine("#INFO: Delete rows from dataset");
                    object usrPk = 1;
                    DataRow[] foundRows = users.Select("Email LIKE '%@example.com'");

                    if (foundRows != null && foundRows.Length > 0)
                    {
                        Console.WriteLine("#INFO: Found {0} entries matching search criteria", foundRows.Length);
                        foreach (DataRow ur in foundRows)
                        {
                            ur.Delete();
                        }
                    }

                    userAdapter.Update(dataSet, "User");

                    Console.WriteLine("#INFO: Users after delete:");
                    PrintTable(users);

                    // add row
                    DataRow row = users.NewRow();

                    row["UserName"] = "alex";
                    row["Email"] = "alex@bmstu.ru";

                    users.Rows.Add(row);

                    Console.WriteLine("#INFO: Users after add:");
                    PrintTable(users);

                    userAdapter.Update(dataSet, "User");
                    Console.WriteLine($"Row id: {outIdParam.Value}");
                    PrintTable(users);
                    //Console.WriteLine("#INFO: Table content after all operations:");
                    //utils.PrintSelect("[User]", new string[] { "Email", "UserName", "About" });
            } catch (Exception ex)
            {
                Console.WriteLine("#ERROR: " + ex.Message);
            }
        }
    }
}
