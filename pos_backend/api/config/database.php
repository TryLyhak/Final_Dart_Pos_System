<?php
class Database
{
	private $host = "localhost";
	private $username = "root";
	private $password = "";
	private $db_name = "pos_db";
	private $port = 3306;


	public function connect(): mysqli
	{
		mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
		$conn = mysqli_init();
		if (!$conn) {
			die(json_encode([
				'success' => false,
				'message' => 'Failed to initialize MySQLi.'
			]));
		}

		$conn->options(MYSQLI_OPT_CONNECT_TIMEOUT, 5);

		try {
			$conn->real_connect($this->host, $this->username, $this->password, $this->db_name, $this->port);
			$conn->set_charset("utf8mb4");
			return $conn;
		} catch (mysqli_sql_exception $e) {
			die(json_encode([
				'success' => false,
				'message' => 'Connection failed: ' . $e->getMessage()
			]));
		}
	}
}
