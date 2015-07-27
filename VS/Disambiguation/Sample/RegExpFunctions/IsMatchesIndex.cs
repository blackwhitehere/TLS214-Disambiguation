using System.Text;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static int? IsMatchesIndex(string input, string pattern, int count)
    {
        Match match = Regex.Match(input, pattern, RegexOptions.CultureInvariant | RegexOptions.Compiled);
        int c = 1;
        if (match.Success & count == 1)
        {
            return match.Index;
        }
        while (match.Success)
        {
            if (c == count)
            {
                return match.Index;
            }
            match = match.NextMatch();
            c = c + 1;
        }
        return null;
    }
}
