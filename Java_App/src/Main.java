import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;

public class Main {

    private static final String URL =
        "jdbc:oracle:thin:@//127.0.0.1:1521/FREEPDB1";
    private static final String USER = "DBMS_PROJECT";
    private static String password;

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, password);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            try {
                UIManager.setLookAndFeel(
                    UIManager.getSystemLookAndFeelClassName()
                );
            } catch (Exception ignored) {}

            JPasswordField field = new JPasswordField(20);
            JPanel panel = new JPanel(new GridLayout(0, 1, 5, 5));
            panel.add(new JLabel("Enter DBMS_PROJECT database password:"));
            panel.add(field);

            int choice = JOptionPane.showConfirmDialog(
                null, panel, "Database Login",
                JOptionPane.OK_CANCEL_OPTION,
                JOptionPane.PLAIN_MESSAGE
            );

            if (choice != JOptionPane.OK_OPTION) return;

            password = new String(field.getPassword());
            field.setText("");

            try (Connection conn = getConnection()) {
                System.out.println("Oracle connection successful!");
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(
                    null, "Database connection failed:\n" + e.getMessage()
                );
                return;
            }

            new Dashboard().setVisible(true);
        });
    }

    static class Dashboard extends JFrame {

        private final JTable studentsTable = new JTable();
        private final JTable examsTable = new JTable();
        private final JTable resultsTable = new JTable();

        private final Map<String, JLabel> counts = new LinkedHashMap<>();

        Dashboard() {
            setTitle("Online Examination Management System");
            setSize(1100, 720);
            setMinimumSize(new Dimension(850, 550));
            setLocationRelativeTo(null);
            setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            setLayout(new BorderLayout(10, 10));

            JLabel heading = new JLabel(
                "  ONLINE EXAMINATION MANAGEMENT SYSTEM"
            );
            heading.setFont(new Font("Arial", Font.BOLD, 22));
            heading.setBorder(BorderFactory.createEmptyBorder(18, 10, 18, 10));
            add(heading, BorderLayout.NORTH);

            JTabbedPane tabs = new JTabbedPane();
            tabs.addTab("Take Examination", new TakeExamPanel());
            tabs.addTab("Administration", new AdminPanel());
            tabs.addTab("Dashboard", createDashboardPanel());
            tabs.addTab("Students", createTablePanel(studentsTable,
                "SELECT student_id, reg_no, student_name, email, " +
                "semester, status FROM student ORDER BY student_id"));

            tabs.addTab("Examinations", createTablePanel(examsTable,
                "SELECT e.exam_id, e.exam_title, c.course_name, " +
                "e.exam_date, e.duration_min, e.total_marks, e.status " +
                "FROM exam e JOIN course c ON c.course_id = e.course_id " +
                "ORDER BY e.exam_id"));

            tabs.addTab("Results", createTablePanel(resultsTable,
                "SELECT r.result_id, s.reg_no, s.student_name, " +
                "e.exam_title, r.score, r.percentage, r.grade, " +
                "r.attempt_date FROM result r " +
                "JOIN student s ON s.student_id = r.student_id " +
                "JOIN exam e ON e.exam_id = r.exam_id " +
                "ORDER BY r.result_id"));

            add(tabs, BorderLayout.CENTER);

            JLabel footer = new JLabel(
                "  Connected to Oracle AI Database 26ai | DBMS_PROJECT"
            );
            footer.setBorder(BorderFactory.createEmptyBorder(8, 10, 12, 10));
            add(footer, BorderLayout.SOUTH);

            refreshAll();
        }

        private JPanel createDashboardPanel() {
            JPanel panel = new JPanel(new BorderLayout(15, 15));
            panel.setBorder(BorderFactory.createEmptyBorder(25, 25, 25, 25));

            JLabel welcome = new JLabel(
                "<html><h2>Welcome!</h2>" +
                "Manage students, examinations and results.</html>"
            );
            panel.add(welcome, BorderLayout.NORTH);

            JPanel grid = new JPanel(new GridLayout(2, 4, 15, 15));

            String[] tables = {
                "STUDENT", "FACULTY", "DEPARTMENT", "COURSE",
                "ENROLLMENT", "EXAM", "QUESTION", "RESULT"
            };

            for (String table : tables) {
                JPanel card = new JPanel(new GridLayout(2, 1, 5, 5));
                card.setBorder(BorderFactory.createCompoundBorder(
                    BorderFactory.createLineBorder(Color.LIGHT_GRAY),
                    BorderFactory.createEmptyBorder(15, 10, 15, 10)
                ));

                JLabel name = new JLabel(table, JLabel.CENTER);
                name.setFont(new Font("Arial", Font.BOLD, 15));

                JLabel value = new JLabel("...", JLabel.CENTER);
                value.setFont(new Font("Arial", Font.BOLD, 27));

                counts.put(table, value);
                card.add(name);
                card.add(value);
                grid.add(card);
            }

            panel.add(grid, BorderLayout.CENTER);

            JButton refresh = new JButton("Refresh Dashboard");
            refresh.addActionListener(e -> refreshAll());
            panel.add(refresh, BorderLayout.SOUTH);

            return panel;
        }

        private JPanel createTablePanel(JTable table, String sql) {
            JPanel panel = new JPanel(new BorderLayout(8, 8));
            panel.setBorder(BorderFactory.createEmptyBorder(12, 12, 12, 12));

            table.setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
            table.setRowHeight(25);
            table.setFillsViewportHeight(true);

            JScrollPane scroll = new JScrollPane(table);
            panel.add(scroll, BorderLayout.CENTER);

            JButton refresh = new JButton("Refresh");
            refresh.addActionListener(e -> {
                try (Connection conn = getConnection()) {
                    loadTable(conn, table, sql);
                } catch (SQLException ex) {
                    showError(ex);
                }
            });

            panel.add(refresh, BorderLayout.SOUTH);
            return panel;
        }

        private void refreshAll() {
            try (Connection conn = getConnection()) {
                for (String table : counts.keySet()) {
                    String sql = "SELECT COUNT(*) FROM " + table;
                    try (Statement st = conn.createStatement();
                         ResultSet rs = st.executeQuery(sql)) {
                        if (rs.next()) {
                            counts.get(table).setText(
                                String.valueOf(rs.getInt(1))
                            );
                        }
                    }
                }

                loadTable(conn, studentsTable,
                    "SELECT student_id, reg_no, student_name, email, " +
                    "semester, status FROM student ORDER BY student_id");

                loadTable(conn, examsTable,
                    "SELECT e.exam_id, e.exam_title, c.course_name, " +
                    "e.exam_date, e.duration_min, e.total_marks, e.status " +
                    "FROM exam e JOIN course c ON c.course_id = e.course_id " +
                    "ORDER BY e.exam_id");

                loadTable(conn, resultsTable,
                    "SELECT r.result_id, s.reg_no, s.student_name, " +
                    "e.exam_title, r.score, r.percentage, r.grade, " +
                    "r.attempt_date FROM result r " +
                    "JOIN student s ON s.student_id = r.student_id " +
                    "JOIN exam e ON e.exam_id = r.exam_id " +
                    "ORDER BY r.result_id");

            } catch (SQLException e) {
                showError(e);
            }
        }

        private void loadTable(
            Connection conn, JTable table, String sql
        ) throws SQLException {

            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(sql)) {

                ResultSetMetaData meta = rs.getMetaData();
                int columns = meta.getColumnCount();

                DefaultTableModel model = new DefaultTableModel();

                for (int i = 1; i <= columns; i++) {
                    model.addColumn(meta.getColumnLabel(i));
                }

                while (rs.next()) {
                    Object[] row = new Object[columns];

                    for (int i = 1; i <= columns; i++) {
                        row[i - 1] = rs.getObject(i);
                    }

                    model.addRow(row);
                }

                table.setModel(model);
            }
        }

        private void showError(Exception e) {
            JOptionPane.showMessageDialog(
                this,
                e.getMessage(),
                "Database Error",
                JOptionPane.ERROR_MESSAGE
            );
        }
    }
}
