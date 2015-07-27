using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static SqlString RemoveDiacritics2(string input)
    {
        bool test = input.IsNormalized();
        if (test == true)
        {
            return input.Normalize();
        }
        return new SqlString(input);
    }
}
