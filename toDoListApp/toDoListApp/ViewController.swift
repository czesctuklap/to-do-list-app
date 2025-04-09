import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var items = [String]()
    var selectedItemIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        title = "to-do list"
        view.addSubview(table)
        table.dataSource = self
        table.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(delTask))
    }
    
    @objc private func delTask() {
        guard let indexPath = selectedItemIndex else {
            let alert = UIAlertController(title: "no task selected", message: "select a task you want to delete first!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "delete task", message: "do you want to delete this task?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "delete", style: .destructive, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.items.remove(at: indexPath.row)
            UserDefaults.standard.set(self.items, forKey: "items")
            self.table.deleteRows(at: [indexPath], with: .automatic)
            self.selectedItemIndex = nil
        }))
        present(alert, animated: true)
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "new task", message: "what do you plan on doing?", preferredStyle: .alert)
        alert.addTextField{field in
            field.placeholder = "i want to ..."
        }
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "add", style: .default, handler: { [weak self] (_) in
            if let field = alert.textFields?.first {
                if let text = field.text, !text.isEmpty{
                    //print(text)
                    DispatchQueue.main.async {
                        var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                        currentItems.append(text)
                        let newEntry = [text]
                        UserDefaults.standard.setValue(newEntry, forKey: "items")
                        self?.items.append(text)
                        self?.table.reloadData()
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let alert = UIAlertController(title: "delete all tasks?", message: "are you sure you want to delete all tasks?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "delete", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                self.items.removeAll()
                UserDefaults.standard.set(self.items, forKey: "items")
                self.table.reloadData()
            }))
            
            present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItemIndex = indexPath // zaznaczanie elementu
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
}
