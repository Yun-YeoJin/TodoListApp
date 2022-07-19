

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
    
    var priority: PriorityLevel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
      
    }
    
    // 버튼 테두리 설정
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        LowButton.layer.cornerRadius = LowButton.bounds.height / 2
        NormalButton.layer.cornerRadius = NormalButton.bounds.height / 2
        HighButton.layer.cornerRadius = HighButton.bounds.height / 2
    }

    @IBAction func SetPriority(_ sender: UIButton) {
        
        LowButton.backgroundColor = .clear
        NormalButton.backgroundColor = .clear
        HighButton.backgroundColor = .clear
        // Low:1, Normal:2, High:3 (tag 설정)
        switch sender.tag {
        case 1: priority = .level1
            LowButton.backgroundColor = priority?.color
        case 2: priority = .level2
            NormalButton.backgroundColor = priority?.color
        case 3: priority = .level3
            HighButton.backgroundColor = priority?.color
        default:
            break
            
        }
        
    }
    
    // SAVE 버튼 클릭시 값 저장.
    @IBAction func SaveTodo(_ sender: Any) {
      
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
        
        delegate?.didFinishSaveData() //화면 갱신하기
        self.dismiss(animated: true, completion: nil) // 화면 내리기
    }
    
  

}
