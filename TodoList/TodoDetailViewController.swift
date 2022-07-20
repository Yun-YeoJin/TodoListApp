

import UIKit
import CoreData



protocol TodoDetailViewControllerDelegate: AnyObject {
    func didFinishSaveData() //호출을 할 수 있는 상황에만 호출
}

class TodoDetailViewController: UIViewController {

    
    weak var delegate: TodoDetailViewControllerDelegate?
    
    @IBOutlet weak var titleTextField: UILabel!
    
    @IBOutlet weak var LowButton: UIButton!
    @IBOutlet weak var NormalButton: UIButton!
    @IBOutlet weak var HighButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var selectedTodoList: TodoList? //띄우고 없었을때는 처리 안하기 위해서 옵셔널
    
    var priority: PriorityLevel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
      
    }
    
    //화면이 나타나기 시작할 때
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let hasData = selectedTodoList {
            titleTextField.text = hasData.title
            
            priority = PriorityLevel(rawValue: hasData.priorityLevel) //priority 세팅
            
            makePriorityButtonDesign()
            
            deleteButton.isHidden = false
            saveButton.setTitle("Update", for: .normal)
        } else {
            deleteButton.isHidden = true
            saveButton.setTitle("Save", for: .normal)
            }
        }
    
    
    // 버튼 테두리 설정
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        LowButton.layer.cornerRadius = LowButton.bounds.height / 2
        NormalButton.layer.cornerRadius = NormalButton.bounds.height / 2
        HighButton.layer.cornerRadius = HighButton.bounds.height / 2
    }

    // 버튼 눌렀을 때 색상 설정
    @IBAction func SetPriority(_ sender: UIButton) {
        // Low:1, Normal:2, High:3 (tag 설정)
        switch sender.tag {
        case 1: priority = .level1
        case 2: priority = .level2
        case 3: priority = .level3
        default:
            break
        }
        
        makePriorityButtonDesign()
      
    }
    // priority에 따라 버튼디자인 변경
    func makePriorityButtonDesign() {
        LowButton.backgroundColor = .clear
        NormalButton.backgroundColor = .clear
        HighButton.backgroundColor = .clear
        
        switch self.priority {
        case .level1:
        LowButton.backgroundColor = priority?.color
        case .level2:
        NormalButton.backgroundColor = priority?.color
        case .level3:
        HighButton.backgroundColor = priority?.color
        default:
            break
        }
    }
    
    // SAVE 버튼 클릭시 값 저장.
    @IBAction func SaveTodo(_ sender: Any) {
      
        if selectedTodoList != nil {
            updateTodo()
        } else {
            saveTodo()
        }
        
        delegate?.didFinishSaveData() //화면 갱신하기
        self.dismiss(animated: true, completion: nil) // 화면 내리기
    }
    
    func saveTodo() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // 엔티티에 저장되어야 한다.
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "TodoList", in: context) else {
            return
        }
        //object 구조 잡기.
        guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? TodoList else{
            return
        }
        object.title = titleTextField.text //textField에 쓰여진 값을 엔티티의 title값에 넣는다.
        object.date = Date()    // 저장하는 순간의 시간을 넣겠다.
        object.uuid = UUID()
        
        object.priorityLevel = priority?.rawValue ?? PriorityLevel.level1.rawValue
        
        let appdelegate = (UIApplication.shared.delegate as! AppDelegate)
        appdelegate.saveContext()
    }
    
    func updateTodo() {
        
        guard let hasData = selectedTodoList else {
            return
        }
        guard let hasUUID = hasData.uuid else {
            return
        }
        
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest() // 불러올 준비
        
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
       // 선택한 uuid만 가져오겠다.
        
        do {
        let loadedData = try context.fetch(fetchRequest)
            
            loadedData.first?.title = titleTextField.text
            loadedData.first?.date = Date()
            loadedData.first?.priorityLevel = self.priority?.rawValue ?? PriorityLevel.level1.rawValue //Local DB에 저장되는 것은 rawValue의 값
            
        } catch {
            print(error)
        }
    }
    
    @IBAction func deleteTodo(_ sender: UIButton) {
        guard let hasData = selectedTodoList else {
            return
        }
        guard let hasUUID = hasData.uuid else {
            return
        }
        
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
      
        do {
            
        let loadedData = try context.fetch(fetchRequest)
            
            if let loadFirstData = loadedData.first{
            context.delete(loadFirstData)
                let appdelegate = (UIApplication.shared.delegate as! AppDelegate)
                appdelegate.saveContext()
        }
        } catch {
            print(error)
        }
        delegate?.didFinishSaveData()
        self.dismiss(animated: true)
        
        }
    
}
