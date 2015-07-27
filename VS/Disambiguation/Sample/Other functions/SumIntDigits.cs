using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Collections.Generic;
using System.Text;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static int? SumIntDigits(string s)
    {
        int ret = 0;
        if (!String.IsNullOrEmpty(s))
        {
            foreach (char c in s)
                ret += c - '0';
            return ret;
        }
        return null;

    }
}
