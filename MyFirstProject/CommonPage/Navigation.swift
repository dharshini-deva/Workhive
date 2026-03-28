//
//  Navigation.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//

import SwiftUI



enum AppRoute: Hashable {
    
    case login
    case adminlogin
    case emplogin
    case dirlogin
    case hrlogin
    case manlogin
    case dirNotifi
    case dirCreatenotifi
    case empnotifi
    case empleave
    case updatetask
    case empschedule
    case mannotifi
    case mancreatenotifi
    case manreq
    case Mancp
   
    case manct
    case ManTO
    case Hrnotifi
    case hrLeave
    
    case hrpro
    case createacc(String)
    
    case hrEmployeeDetail
    case adminuseredit(AdminUser)
    
    case empchatbot
    
    // ✅ NEW Route: Manager Review Task
    case managerReviewTask(ManagerPendingTask)

}

struct NavigationViews: View {
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            
            AppHomePageView(path: $path)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView(path: $path)
                        
                    case .adminlogin:
                        AdminTab(path: $path)
                            .frame(maxWidth: .infinity)
                        
                    case .emplogin:
                        EmpTab(path: $path)
                        
                    case .dirlogin:
                        DirTab(path: $path)
                   
                    case .hrlogin:
                        DashboardView(path: $path)
                        
                    case .manlogin:
                        ManTab(path: $path)
                        
                    case .dirNotifi:
                        DirNotificationsView(path: $path)
                        
                    case .dirCreatenotifi:
                        DirCreateNotificationView(path: $path)
                        
                    case .empnotifi:
                        NotificationsView(path: $path)
                        
                    case .empleave:
                        EmpLeaveRequestView(path: $path)
                        
                    case .updatetask:
                        UpdateTodayTaskView(path: $path)
                        
                    case .empschedule:
                        AddReminderView(path: $path)
                        
                    case .mannotifi:
                        ManNotificationsView(path: $path)
                        
                    case.mancreatenotifi:
                        ManCreateNotificationView(path: $path)
                    
                    case .manreq:
                        SendRequestView(path: $path)
                       
                    case .Mancp:
                        AddClientProjectView(path: $path)
                        
                    case .manct:
                        CreateTeamView(path:$path)
                        
                    case.ManTO:
                        ManTeamsView(path: $path)
                        
                   
                    case .Hrnotifi:
                        HrNotificationsView(path: $path)
                        
                    case .hrLeave:
                        HrLeaveView(path: $path)

                    
                    case .hrpro:
                        HrProfileView(path: $path)
                        
                    case .hrEmployeeDetail:
                        EmployeeDetailsView()

                        
                    case .createacc(let role):
                        CreateProfileView(type:role,path: $path)
                        
                    case .empchatbot:
                        EmpChatbotView(path: $path)
                        
                    case .adminuseredit(let user):
                        AdminEditUserView(user: user, path: $path)
                        
                    case .managerReviewTask(let task):
                        ManagerTaskDetailView(path: $path, task: task)
                    }
                }
        }
    }
}
//
