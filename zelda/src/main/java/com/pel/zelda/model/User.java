package com.pel.zelda.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * User: bharat
 * Date: 8/9/21
 * Time: 4:34 PM
 */
public class User {

    public String id;
    public String firstName;
    public String lastName;
    public String email;
    public String gender;
    public String school;
    public Integer gradYear;
    public String profilePicture;
    public Timestamp createdAt;
    public Timestamp updatedAt;

    public List<String> roles = new ArrayList<>();
    public Connection connections = new Connection();
    public Verification verification = new Verification();

}
