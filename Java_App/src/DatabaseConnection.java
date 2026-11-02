import java.sql.*;
import java.io.Console;
import java.util.Arrays;

public class DatabaseConnection {

    private static final String URL =
        "jdbc:oracle:thin:@//127.0.0.1:1521/FREEPDB1";

    private static final String USER = "DBMS_PROJECT";

    public static void main(String[] args) {

        Console console = System.console();

        if (console == null) {
            System.out.println("Please run this from Mac Terminal.");
            return;
        }

        char[] passwordChars =
            console.readPassword("Enter Oracle DBMS_PROJECT password: ");

        if (passwordChars == null || passwordChars.length == 0) {
            System.out.println("Password cannot be empty.");
            return;
        }

        String password = new String(passwordChars);
        Arrays.fill(passwordChars, '\0');

        try {
            Class.forName("oracle.jdbc.OracleDriver");

            try (Connection conn =
                     DriverManager.getConnection(URL, USER, password);
                 Statement stmt = conn.createStatement();
                 ResultSet rs =
                     stmt.executeQuery("SELECT COUNT(*) FROM STUDENT")) {

                System.out.println("\n====================================");
                System.out.println(" ORACLE DATABASE CONNECTED!");
                System.out.println("====================================");

                if (rs.next()) {
                    System.out.println(
                        "Total students in database: " + rs.getInt(1)
                    );
                }

                System.out.println("Connection successful!");

            }

        } catch (Exception e) {
            System.out.println("\nConnection failed:");
            System.out.println(e.getMessage());
        }
    }
}
