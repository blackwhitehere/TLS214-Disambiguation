using System.Text;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static string RegexSplit(string input, string pattern)
    {
        string[] result = Regex.Split(input, pattern, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);
        string result_output = "";

        if ((result != null || result.Length > 0))
        {
            for (int ctr = 0; ctr < result.Length; ctr++)
            {
                result_output = result_output + result[ctr];
                //if (ctr < result.Length - 1)
                //{
                //    result_output = result_output + "| ";
                //}
            }
            return result_output;
        }
        return string.Empty;
    }
}
