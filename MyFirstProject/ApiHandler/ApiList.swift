//
//  ApiList.swift
//  WorkHive
//
//  Created by SAIL on 26/12/25.
//
import UIKit

struct ServiceApi {
    
    static let BaseUrl = "http://localhost/myworkhive/"
    
    static let Login = BaseUrl+"login.php"
    
    static let createAccount = BaseUrl+"create_user.php"
    
    static let createLeave = BaseUrl + "create_leave_request.php"
    
    //static let getAllLeaves = BaseUrl + "get_all_leave_requests.php"
    
    static let getPendingLeaves = BaseUrl + "get_pending_leaves.php"
    
    static let processLeave     = BaseUrl + "process_leave_request.php"
    
    static let getEmployeeNotifications = BaseUrl + "get_notifications.php"
    
    static let createproject = BaseUrl + "create_project.php"
    
    static let getprofile = BaseUrl + "get_profile.php"
    
    static let createTeam = BaseUrl + "create_team.php"
    
    static let getUsers = BaseUrl + "get_users.php"//create team
    
    static let getProjects = BaseUrl + "get_projects.php"

    static let getTeams = BaseUrl + "get_teams.php" // Teams
    
    static let getEmployeeProjects = BaseUrl + "get_employee_projects.php" //employee project
    
    static let getManagerProjects = BaseUrl + "get_manager_projects.php"

    static let createManagerRequest = BaseUrl + "create_manager_request.php"
    
    static var getDirectorRequests =
        BaseUrl + "get_director_requests.php"
    
    static var processManagerRequest =
            BaseUrl + "process_manager_request.php"
    
    static var getDirectorProjects = BaseUrl + "get_director_projects.php"
    
    static var getDirectorTeams = BaseUrl + "get_director_teams.php"
    
    static let getDirectorTeamDetail =
            BaseUrl + "get_director_team_detail.php"
    
    static let getManagerTeams =
        BaseUrl + "get_manager_teams.php"//manager getTeamsOverview
    
    static let addDailyTask = BaseUrl + "employee_add_daily_task.php"
    static let getDailyTasks = BaseUrl + "get_employee_daily_tasks.php" // ✅ NEW Endpoint
    
    // ✅ NEW: Manager Dashboard - Pending Tasks
    static let managerGetPendingTasks = BaseUrl + "manager_get_pending_tasks.php"
    static let managerReviewTask = BaseUrl + "manager_review_task.php"
    
    static let createReminder = BaseUrl + "add_reminder.php"
    
    static let getReminders   = BaseUrl + "get_employee_reminders.php"
    
    static let getProfiles = BaseUrl + "get_hr.php"
    
    static let getAdmin = BaseUrl + "admin_fetch_users.php"
    
    static let deleteAdminUser = BaseUrl + "admin_delete_user.php"
    
    static let updateAdminUser = BaseUrl + "admin_update_user.php"

}
