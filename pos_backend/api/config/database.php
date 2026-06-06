<?php
class Database
{
    private $hostname = 'localhost';
    private $username = 'root';
    private $password = '';
    private $database = 'pos_db';
    private $connection;

    public function connect()
    {
        if ($this->connection === null) {
            $this->connection = new mysqli(
                $this->hostname,
                $this->username,
                $this->password,
                $this->database
            );

            if ($this->connection->connect_error) {
                die('Database connection failed: ' . $this->connection->connect_error);
            }
        }

        return $this->connection;
    }
}
