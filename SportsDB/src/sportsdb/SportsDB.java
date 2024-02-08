/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package sportsdb;

import java.sql.*;


/**
 *
 * @author John Deliveis
 */
public class SportsDB {

    static String driverClassName = "org.postgresql.Driver" ;
    static String url = "jdbc:postgresql://localhost:5432/testdb" ;
    static Connection dbConnection = null;
    static Statement statement = null;
    public static void main(String[] args) {
        LoginForm login=new LoginForm();
        login.setVisible(true);        
    }
    
}
