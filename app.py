import tkinter as tk
from tkinter import *
from tkinter import ttk
import customtkinter as ctk
from tkinter.messagebox import showinfo

import cx_Oracle

dsn_tns = cx_Oracle.makedsn('localhost', '1521') # if needed, place an 'r' before any parameter in order to address special characters such as '\'.


ctk.set_appearance_mode("Light")
ctk.set_default_color_theme("blue")

class App:
    def __init__(self) -> None:
        self.root_win = ctk.CTk()
        self.root_win.geometry(f"{1500}x{700}")
        self.root_win.resizable(False, False)
        self.root_win.title("Database Assignment App")
        self.root_win.configure(bg="gray17")

        #Login page:
        self.conn = None    #oracle connection
        self.c = None       #oracle cursor
        self.firstLogin = True
        self.frame_loginPage = tk.Frame(master=self.root_win, bg = "white")
        self.label_login = tk.Label(master=self.frame_loginPage, text='Login as system admin:',
                                    font=('Arial', 25, 'bold'), bg='white')
        
        self.usernameString = tk.StringVar()
        self.passString = tk.StringVar()
        self.entry_username = ctk.CTkEntry( master=self.frame_loginPage, placeholder_text="Enter user name", 
                                            text_font=('Arial', 14), width=200)
        self.entry_pass = ctk.CTkEntry( master=self.frame_loginPage, placeholder_text="Enter password", show='*',
                                        text_font=('Arial', 14), width=200)
        
        self.button_login = ctk.CTkButton(  master=self.frame_loginPage, text="Login",
                                            text_font=('Arial', 14), width=150, height=35,
                                            command=self.loginButton)
        self.label_loginFail = tk.Label(master=self.frame_loginPage, text="Login failed", fg='red')

        #Side bar
        self.sidebar = tk.Frame(master=self.root_win, bg = "gray23", width='20')
    
        self.button_materialPurchases = ctk.CTkButton(   self.sidebar, text=" Suppliers ", corner_radius=0, height=40,
                                                    fg_color='gray23', text_font=('Arial',12), text_color='white', text_color_disabled='white', hover_color='gray30',
                                                    command= self.materialPurchases_button)
        self.separator = tk.Frame(self.sidebar, bg="gray28", height=1, bd=0)

        self.button_orderReport = ctk.CTkButton( self.sidebar, text=" Order reports ", corner_radius=0, height=40,
                                            fg_color='gray23', text_font=('Arial',12), text_color='white', text_color_disabled='white', hover_color='gray30',
                                            command= self.orderReport_button)

        self.button_logout = ctk.CTkButton( self.sidebar, text=" Log out ", corner_radius=0, height=40,
                                            fg_color='gray30', text_font=('Arial',12), text_color='white', text_color_disabled='white', hover_color='gray50',
                                            command= self.logout_button)

        #main pannel
        self.frame_mainPannel = tk.Frame(master=self.root_win, bg = "white")
        self.frame_mainPannel.grid_rowconfigure(0, weight=1)
        self.frame_mainPannel.grid_columnconfigure(0, weight=1)

        #material purchases page
        self.frame_materialPurchases = tk.Frame(self.frame_mainPannel, background = "gray18")
        self.entry_searchBar = ctk.CTkEntry(master=self.frame_materialPurchases, placeholder_text="Search for name or phone number...",
                                            text_font=('Arial', 14))
        self.button_search = ctk.CTkButton( master=self.frame_materialPurchases, text="Search", text_color='white',
                                            text_font=('Arial', 14), width=100, fg_color='grey25',
                                            command=self.searchButton)

        #suppliers table
        columns = ('code','name', 'address', 'bank', 'tax', 'phone')
        self.tree_suppliers = ttk.Treeview(self.frame_materialPurchases, columns=columns, show='headings', selectmode='browse')
        self.tree_suppliers.heading('code', text='Code')
        self.tree_suppliers.heading('name', text='Name')
        self.tree_suppliers.heading('address', text='Address')
        self.tree_suppliers.heading('bank', text='Bank account')
        self.tree_suppliers.heading('tax', text='Tax code')
        self.tree_suppliers.heading('phone', text='Phone numbers')
        

        def item_selected(event):   #display Categories provided by selected Supplier in a popup window
            for selected_item in self.tree_suppliers.selection():
                item = self.tree_suppliers.item(selected_item)
                record = item['values']
                # get supplier's ID
                suppID = record[0]
                # print(suppID)

                #Generate popup window: supply tab and categories tab of currently selected supplier
                popUp = Toplevel(self.root_win)
                popUp.geometry("1000x250")
                popUp.title(f"Supply info of {record[1]}")

                #2 tabs of the popup window
                tabControl = ttk.Notebook(popUp)
                tab1 = ttk.Frame(tabControl)
                tab2 = ttk.Frame(tabControl)
                tabControl.add(tab1, text ='Categories')
                tabControl.add(tab2, text ='Orders')
                tabControl.pack(expand = 1, fill ="both")
                
                #tab1: orders the supplier supplied
                supplyColumns = ('category','date', 'quantity', 'price')
                tree_supplies = ttk.Treeview(tab2, columns=supplyColumns, show='headings', selectmode='browse')
                tree_supplies.heading('category', text='Category')
                tree_supplies.heading('date', text='Date')
                tree_supplies.heading('quantity', text='Quantity')
                tree_supplies.heading('price', text='Purchased price')
                tree_supplies.pack(fill='both', expand=True)

                # Query all orders of a supplier via suppID
                self.c.execute('select CATEGORY.*, newest_price.price from CATEGORY, newest_price where S_CODE = :ID and CATEGORY.c_code = newest_price.c_code', ID = suppID)
                rows = self.c.fetchall()

                for row in rows:
                    tree_supplies.insert('', 'end', values= (row[1], row[5], row[6], row[7]))

                #tab2: tree of categories the suppliers supplied
                categoriesColumns = ('code','name', 'color', 'quantity', 'prices')
                tree_categories = ttk.Treeview(tab1, columns=categoriesColumns, show='headings', selectmode='browse')
                tree_categories.heading('code', text='Code')
                tree_categories.heading('name', text='Category name')
                tree_categories.heading('color', text='Color')
                tree_categories.heading('quantity', text='Quantity')
                tree_categories.heading('prices', text='Current prices')
                tree_categories.pack(fill='both', expand=True)
                # Query all categories from a supplier via suppID
                

                for row in rows:
                    tree_categories.insert('', 'end', values= (row[0], row[1],row[2],f'{row[3]} rolls',row[8]))

                def displayPrices(event):
                    for selected_category in tree_categories.selection():
                        item = tree_categories.item(selected_category)
                        record = item['values']
                        # get category's ID
                        catCode = record[0]

                        #Display all prices of a category in a tree
                        pricePopup = Toplevel(popUp)
                        pricePopup.title(f'Pricing history of {record[1]}')
                        pricePopup.geometry('600x200')

                        pricesColumns = ('price','date')
                        tree_prices = ttk.Treeview(pricePopup, columns=pricesColumns, show='headings', selectmode='browse')
                        tree_prices.heading('price', text='Price')
                        tree_prices.heading('date', text='Set date')

                        #Query prices and dates via catCode
                        self.c.execute('select * from CURRENT_PRICE where C_CODE = :code', code = catCode)
                        rows = self.c.fetchall()

                        for row in rows:
                            tree_prices.insert('', 'end', values= (row[1],row[2]))


                        tree_prices.pack(fill='both', expand=True)


                tree_categories.bind('<<TreeviewSelect>>', displayPrices)


        self.tree_suppliers.bind('<<TreeviewSelect>>', item_selected)

        self.button_addSupplier = ctk.CTkButton(master=self.frame_materialPurchases, text="Add new supplier", text_color='white',
                                                text_font=('Arial', 14), width=120, fg_color='grey25',
                                                command=self.addSupplierButton)
        self.button_addSupplier.pack(side='bottom', padx=(1200,10), pady=(10,10))

        #Order report page
        self.frame_orderReport = tk.Frame(self.frame_mainPannel, bg = "gray18")
        
        #Customers table
        cusColumns = ('code','fname', 'lname')
        self.tree_customers = ttk.Treeview(self.frame_orderReport, columns=cusColumns, show='headings', selectmode='browse')
        self.tree_customers.heading('code', text='Code')
        self.tree_customers.heading('fname', text='First Name')
        self.tree_customers.heading('lname', text='Last Name')
        self.selectedCus = -1   # code of selected customer in the table
        
        def customer_selected(event):
            for selected_cus in self.tree_customers.selection():
                item = self.tree_customers.item(selected_cus)
                record = item['values']
                # get selected customer's ID
                cusCode = record[0]
                self.selectedCus = cusCode

        self.tree_customers.bind('<<TreeviewSelect>>', customer_selected)

    def renderLoginPage(self):
        self.frame_loginPage.pack(fill='both', expand=True)
        self.label_login.pack(pady=(100,100))
        self.entry_username.pack(pady=(0,10))
        self.entry_pass.pack(pady=(0,20))
        self.button_login.pack()

    def displayAllSuppliers(self):
        # Display all suppliers at startup

        self.c.execute('select * from supplier left join sup_phone_numbers on supplier.s_code = sup_phone_numbers.s_code order by supplier.s_code')
        rows = self.c.fetchall()
        # for n in range(1, 100):
        #     self.tree_suppliers.insert('', 'end', values= (n, f'Name_{n}', f'{n} DT road', f'{n}', f'11{n}22',f'0911_{n}'))
        code_list = []
        suppliers = []

        for row in rows:
            if row[0] in code_list:
                for supplier in suppliers:
                    if supplier[0] == row[0]:
                        supplier[7] += ' , ' + row[7]
            else:
                suppliers.append(list(row))
                code_list.append(row[0])

        # res = []
        # for supplier in suppliers:
        #     for attr in supplier:
        #         if attr.find('800 645 7270') != -1:
        #             res.append(supplier)
        #             break

        # print(res)

        for supplier in suppliers:
            self.tree_suppliers.insert('', 'end', values= (supplier[0], supplier[1], supplier[2], supplier[3], supplier[4], supplier[7]))
            code_list.append(row[0])

    def renderMainPage(self):
        self.sidebar.pack(fill='y', side='left')
        self.button_materialPurchases.pack(fill='x')
        self.separator.pack(fill='x')
        self.separator.pack(fill='x')
        self.button_orderReport.pack(fill='x')
        self.separator.pack(fill='x')
        self.button_logout.pack(fill='x', side='bottom')
        self.frame_mainPannel.pack(fill='both', side = 'right', expand = True)

        #render material purchases page
        self.frame_materialPurchases.grid(row=0, column=0, sticky="nsew")
        self.tree_suppliers.pack(fill='both', expand=True, side='bottom', padx=(10,10), pady=(30,10))
        self.entry_searchBar.pack(fill='x', expand=True, side='left', padx=(100,0), pady=(30,10))
        self.button_search.pack(fill='x', side='right', padx=(0,600), pady=(30,10))

        #render order reports purchases page
        self.frame_orderReport.grid(row=0, column=0, sticky="nsew")
        self.tree_customers.pack(fill='both', expand=True, padx=(30,30), pady=(40,10))
        self.button_report = ctk.CTkButton(master=self.frame_orderReport, text="Generate report", text_color='white',
                                        text_font=('Arial', 14), width=100, fg_color='grey25',
                                        command=self.reportGenerate_button)
        self.button_report.pack(pady=(10,10))
        self.frame_materialPurchases.tkraise()


    def login(self):
        username = self.entry_username.get()
        password = self.entry_pass.get()
        print("Login:", username, ' - ', password)
        try:
            self.conn = cx_Oracle.connect(user=username, password=password, dsn=dsn_tns)
            self.c = self.conn.cursor()
            return True
        except:
            self.entry_pass.delete(0, 'end')
            self.entry_pass.insert(0, '')
            return False

    def loginButton(self):
        if self.login() == True:
            self.entry_pass.delete(0, 'end')
            self.entry_pass.insert(0, '')
            self.frame_loginPage.pack_forget()
            self.label_loginFail.pack_forget()
            self.renderMainPage()
            if self.firstLogin:
                self.displayAllSuppliers()
                self.c.execute('select * from CUSTOMER')
                rows = self.c.fetchall()
                for row in rows:
                    self.tree_customers.insert('','end',values=(row[0], row[1], row[2]))
                self.firstLogin = False
        else:
            print("login failed")
            self.label_loginFail.pack()
    
    def logout_button(self):
        self.conn = None
        self.c = None

        self.frame_mainPannel.pack_forget()
        self.frame_orderReport.pack_forget()
        self.button_report.pack_forget()
        self.sidebar.pack_forget()
        self.frame_loginPage.pack()
        self.renderLoginPage()

    def materialPurchases_button(self):
        self.frame_materialPurchases.tkraise()
    def orderReport_button(self):
        self.frame_orderReport.tkraise()

    def searchButton(self):
        searchInput = self.entry_searchBar.get()
        print("search for:",searchInput)
        # execute search query
        self.c.execute('select * from supplier left join sup_phone_numbers on supplier.s_code = sup_phone_numbers.s_code order by supplier.s_code')
        rows = self.c.fetchall()
        # for n in range(1, 100):
        #     self.tree_suppliers.insert('', 'end', values= (n, f'Name_{n}', f'{n} DT road', f'{n}', f'11{n}22',f'0911_{n}'))
        code_list = []
        suppliers = []

        for row in rows:
            if row[0] in code_list:
                for supplier in suppliers:
                    if supplier[0] == row[0]:
                        supplier[7] += ' , ' + row[7]
            else:
                suppliers.append(list(row))
                code_list.append(row[0])


        #Insert sample data for Supplier table, remember to concacenate all phone numbers
        if searchInput == "*":  
            self.tree_suppliers.delete(*self.tree_suppliers.get_children())
            #display all suppliers when searching for *
            self.displayAllSuppliers()
        else:
            res = []
            for supplier in suppliers:
                for attr in supplier:
                    if (str(attr).lower()).find(searchInput.lower()) != -1:
                        res.append(supplier)
                        break

            self.tree_suppliers.delete(*self.tree_suppliers.get_children())
            #display query result
            for ele in res:
                self.tree_suppliers.insert('', 'end', values= (ele[0], ele[1], ele[2], ele[3], ele[4], ele[7]))
                code_list.append(row[0])
            
    def addSupplierButton(self):
        popUp = Toplevel(self.root_win)
        popUp.geometry("600x500")
        popUp.title("Add new supplier")

        label_name = tk.Label(popUp, text='Name')
        entry_name = ctk.CTkEntry(popUp, width=250)
        label_name.pack()
        entry_name.pack()

        label_addr = tk.Label(popUp, text='Address')
        entry_addr = ctk.CTkEntry(popUp, width=250)
        label_addr.pack()
        entry_addr.pack()

        label_bank = tk.Label(popUp, text='Bank account number')
        entry_bank = ctk.CTkEntry(popUp, width=250)
        label_bank.pack()
        entry_bank.pack()

        label_tax = tk.Label(popUp, text='Tax code')
        entry_tax = ctk.CTkEntry(popUp, width=250)
        label_tax.pack()
        entry_tax.pack()

        label_phonenums = tk.Label(popUp, text='Phone numbers')
        frame_phoneNums = ctk.CTkFrame(popUp, border_color='black', width=180)

        numEntries = []
        def addNumber():
            newNum = ctk.CTkEntry(frame_phoneNums, width=180)
            numEntries.append(newNum)
            newNum.pack()

        button_addNum = ctk.CTkButton(  frame_phoneNums, text='Add number', fg_color='#03fcba', hover_color='gray',
                                        command=addNumber)
        
        label_phonenums.pack()
        frame_phoneNums.pack()
        button_addNum.pack(fill='x')

        def addSupplier():
            name = entry_name.get()
            address = entry_addr.get()
            bankAcc = entry_bank.get()
            taxCode = entry_tax.get()
            phoneNums = []
            for num in numEntries:
                phoneNums.append(num.get())

            print(name, address, bankAcc, taxCode)
            print(phoneNums)

            self.c.execute("""insert into supplier values(:id, :name, :address, :bank_account, :tax_code, :partner_staff_code)""", ['',name, address, bankAcc, taxCode, 'EM040001'])
            self.conn.commit()
            
            self.c.execute("select s_code from supplier where name = :name", name = name)
            id = self.c.fetchone()
            print(id[0])

            for phoneNum in phoneNums:
                self.c.execute("insert into SUP_PHONE_NUMBERS VALUES (:id, :phoneNum)", id = id[0], phoneNum = phoneNum)
                self.conn.commit()

            self.tree_suppliers.delete(*self.tree_suppliers.get_children())
            self.displayAllSuppliers()
        
        button_addSupplier = ctk.CTkButton( popUp, text='Add Supplier', fg_color='#03fcba', hover_color='gray',
                                            command=addSupplier)
        button_addSupplier.pack(side = 'bottom', pady=(5,10))

    def reportGenerate_button(self):
        # query all orders corresponding to self.selectedCus (selected customer's Ccode)
        self.tree_customers.delete(*self.tree_customers.get_children())

        print("Generating report for:",self.selectedCus)

        self.c.execute('select * from CUSTOMER')
        rows = self.c.fetchall()
        for row in rows:
            self.tree_customers.insert('','end',values=(row[0], row[1], row[2]))

        reportWindow = Toplevel(self.root_win)
        reportWindow.geometry('1000x600')
        reportWindow.title('Orders report')

        reportContent = Text(reportWindow)

        self.c.execute('select * from final_ret where cus_code = :cusID order by c_code', cusID = self.selectedCus)
        res = list(self.c.fetchall())
        print(res)
        #Insert report info into reportContent
        separatorLine = '===================================================================================\n'
        
        reportContent.insert('end', f'Order reports for {res[0][11]} {res[0][12]}:\n\n')
        
        categories = []

        for row in res:
            row = list(row)
            categories.append(row[5])

        categories = list(set(categories))

        for category in categories:        # list each category the customer ordered, then list order for each category
            self.c.execute('select Name from CATEGORY where C_CODE = :cat_code ', cat_code = category)
            namerow = self.c.fetchone()
            reportContent.insert('end', f'Order reports for category {namerow[0]}:\n')
            reportContent.insert(   'end', "{:<10} {:<10} {:<10} {:<10} {:<18} {:<25}\n"
                                    .format("Order Code", "Date", "Time", "Total Price", "Status", "Cancel reason"))
            for line in res:    # list info of each order belongs to this category
                line = list(line)
                if line[5] == category:
                    reportContent.insert(   'end', "{:<10} {:<10} {:<10} {:<10} {:<18} {:<25}\n"
                                        .format(line[7], line[0], line[1], line[10], line[3], line[13] if line[13] != None else 'Did not cancel'))
            reportContent.insert('end', separatorLine)
        reportContent.pack(fill='both', expand='true', padx=(15,15), pady=(15,15))


    def run(self):
        self.renderLoginPage()
        self.root_win.mainloop()

instance = App()
instance.run()