
import CoreData
import UIKit

enum PriorityLevel: Int64 {
    case level1 //0 (rawValue)
    case level2 //1
    case level3 //2
}

extension PriorityLevel{
    var color: UIColor {
        switch self {
        case .level1: return .green
        case .level2: return .orange
        case .level3: return .red
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var TodoTableView: UITableView!
    
    //AppDelegate에 접근하는 방법! , 타입 캐스팅 필요함 => AppDelegate에 접근 가능.
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    var todoList = [TodoList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "To Do List" //네비게이션바 상단 title 설정
        makeNavigationBar() // 네비게이션바 디자인 설정
        
        TodoTableView.delegate = self
        TodoTableView.dataSource = self
    
        fetchData()
        TodoTableView.reloadData() //fetch가 먼저 될수도 있기 때문에 굳이 필요하진 않다.
        
    }
    
    func fetchData() { //데이터 불러오기 CoreData를 이용해서 Local DB에 있는 데이터를 불러오는 것.
        //엔티티 가져오기 (TodoList) , 만약 TodoList엔티티가 안불러진다면 Xcode 재부팅
      
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
       
        do{
            self.todoList = try context.fetch(fetchRequest)
        } catch { //못받아오면 error
            print(error)
        }
      
    }
    //오른쪽 상단 (+) 버튼 눌렀을 때 동작
    @objc func addNewTodo() {
        let detailVC = TodoDetailViewController.init(nibName: "TodoDetailViewController", bundle: nil)
        detailVC.delegate = self
        
        self.present(detailVC, animated: true, completion: nil)
        
    }
    
    func makeNavigationBar() {
        
          //네비게이션바 오른쪽 상단 아이템 설정
          let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTodo))
          
          self.navigationItem.rightBarButtonItem = item
          item.tintColor = .black //rightbarButton 색상 수정
          
          // 네비게이션바 배경 색상 설정
          let barAppearance = UINavigationBarAppearance()
          barAppearance.backgroundColor = UIColor.systemMint
          
          self.navigationController?.navigationBar.standardAppearance = barAppearance
          
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    //셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoList.count
    }
    //셀의 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        
        cell.toptitleLabel.text = todoList[indexPath.row].title
        
        if let hasDate = todoList[indexPath.row].date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let dateString = formatter.string(from: hasDate) //hasDate(date) => String타입으로 변환
            cell.dateLabel.text = dateString
        } else {
            cell.dateLabel.text = ""
        }
        let priority = todoList[indexPath.row].priorityLevel // Local DB에 있는 정보 가져옴
        let prioritycolor = PriorityLevel(rawValue: priority)?.color
        cell.prioirtyView.backgroundColor = prioritycolor
        cell.prioirtyView.layer.cornerRadius = cell.prioirtyView.bounds.height / 2
  
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let detailVC = TodoDetailViewController.init(nibName: "TodoDetailViewController", bundle: nil)
        detailVC.delegate = self
        detailVC.selectedTodoList = todoList[indexPath.row]//내가 선택한 값을 넘겨주겠다.
        self.present(detailVC, animated: true, completion: nil)
    }
}
    
extension ViewController: TodoDetailViewControllerDelegate {
    func didFinishSaveData() {
        self.fetchData() //저장된 정보 불러오기
        self.TodoTableView.reloadData() //delegate를 통해서 reloadData가 되게 해준다.
    }
}
