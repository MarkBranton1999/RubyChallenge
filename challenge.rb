require 'json'
class Challenge
    attr_accessor :companies, :users

    def initialize(companies, users)
        @companies = companies
        #sort companies by id in ascending order
        @companies.sort! { |a, b| a['id'] <=> b['id']}
        @users = users
        #sort users alphabetically by last name
        @users.sort! { |a, b| a['last_name'] <=> b['last_name']}
    end

    def processAndWriteToFile
        if @users.nil? || @companies.nil?
            puts 'Error: missing company or user data'
        else
            output = ""
            @companies.each do |comp|
                ##for each company find all users associated with said company, top up their tokens if they are active users and sort the active users into emailed or not emailed based on user and company email status
                emailed_users = []
                users_not_emailed = []
                users_belonging_to_comp = @users.select {|user| user['company_id'] == comp['id']}
                if users_belonging_to_comp.empty?
                    next
                end
                total_top_ups = 0
                users_belonging_to_comp.each do |user|
                    if user['active_status']
                        new_token_balance = user['tokens'] + comp['top_up']
                        total_top_ups += comp['top_up']
                        output_user = "\n\t\t#{user['last_name']}, #{user['first_name']}, #{user['email']}\n\t\t  Previous Token Balance, #{user['tokens']}\n\t\t  New Token Balance #{new_token_balance}"
                        if user['email_status'] && comp['email_status']
                            emailed_users.append(output_user)
                        else
                            users_not_emailed.append(output_user)
                        end
                    end 
                end
                emailed_users = emailed_users.join
                users_not_emailed = users_not_emailed.join
                output << "\n\tCompany Id: #{comp['id']}\n\tCompany Name: #{comp['name']}\n\tUsers Emailed:"
                if !emailed_users.empty?
                    output << "#{emailed_users}"
                end
                output << "\n\tUsers Not Emailed:"
                if !users_not_emailed.empty?
                    output << "#{users_not_emailed}"
                end
                output <<"\n\t\tTotal amount of top ups for #{comp['name']}: #{total_top_ups}\n"
            end
            File.open("output.txt", "w") { |f| f.write(output)}
        end
    end

end


if __FILE__ == $0
    companies_file = File.read('./companies.json')
    companies = JSON.parse(companies_file, symbolize_keys: true)
    users_file = File.read('./users.json')
    users = JSON.parse(users_file, symbolize_keys: true)
    challenge = Challenge.new(companies, users)
    challenge.processAndWriteToFile
end