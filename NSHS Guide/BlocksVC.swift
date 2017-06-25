import UIKit
import JTCalendar

class BlocksVC:UITableViewController, JTCalendarDelegate
{
    @IBOutlet private var monthMenu:JTCalendarMenuView!
    @IBOutlet private var monthView:JTHorizontalCalendarView!
    private let calendarManager = JTCalendarManager()
    private var blockMonthDelegate:BlockMonthDelegate!
    
    //Array of array of TeacherWithBlock
    //1st level = section. [0] gives TeacherWithBlock for 1st day, [1] gives 2nd day, etc
    //2nd level = array of TeacherWithBlock for a particular day.
    private var blocksForSection = [[TeacherWithBlock]]()
    private var dateTextForSection = [String]()
    private var scheduleTypeForSection = [ScheduleType]()
    private var nextDate = LocalDate()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        blockMonthDelegate = BlockMonthDelegate(selectedDateChangeFunc: onSelectedDateChanged)
        setUpBlockMonth()
    }
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        Internet.querySpecialSchedule(completion: nil)
        
        nextDate = LocalDate()
        resetTable()
        jumpToRelevantBlock()
    }
    private func setUpBlockMonth()
    {
        calendarManager.delegate = blockMonthDelegate
        calendarManager.menuView = monthMenu
        calendarManager.contentView = monthView
        calendarManager.setDate(Date())
    }
    private func resetTable()
    {
        self.blocksForSection.removeAll()
        self.dateTextForSection.removeAll()
        self.scheduleTypeForSection.removeAll()
        (0..<7).forEach({_ in self.populateBlocksWithNextDay()})
    }
    private func populateBlocksWithNextDay()
    {
        guard nextDate <= SchoolYear.end else {
            return
        }
        
        let yourAbsentTeacherBlocks = getYourAbsentTeacherBlocks()
        var blockSection = [TeacherWithBlock]()
        
        if let blocks = TeacherManager.getBlocksWithLunches(for: nextDate)
        {
            blocks.forEach({blockSection.append(getTeacherWithBlock($0, yourAbsentTeachers: yourAbsentTeacherBlocks))})
        }
        
        blocksForSection.append(blockSection)
        dateTextForSection.append(nextDate.format("MM/dd EEEE"))
        scheduleTypeForSection.append(Settings.getScheduleType(for: nextDate))
        nextDate = nextDate.add(1, forType: .day)
        tableView.reloadData()
    }
    private func jumpToRelevantBlock()  //this assumes the tableView is showing today's blocks
    {
        if let blocks = TeacherManager.getBlocksWithLunches(for: LocalDate())
        {
            let timeInMinutes = Time().toMinutes()
            
            var relevantIndex = 0
            for block in blocks
            {
                guard timeInMinutes >= block.endTime.toMinutes() else {
                    break
                }
                relevantIndex += 1
            }
            
            if (relevantIndex < blocks.count)
            {
                tableView.scrollToRow(at: IndexPath(row: relevantIndex, section: 0), at: .top, animated: true)
            }
            else
            {
                //if all blocks today have ended, scroll to the beginning of tomorrow
                tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: 1), at: .top, animated: true)
            }
        }
    }
    private func getYourAbsentTeacherBlocks() -> [String]?
    {
        guard nextDate.isToday() else {
            return nil
        }
        return Settings.getYourAbsentTeachersBlocks()
    }
    private func getTeacherWithBlock(_ block:Block, yourAbsentTeachers:[String]?) -> TeacherWithBlock
    {
        let textAndRoomNum = TeacherManager.teacherTextAndRoomNumForBlock(block, yourAbsentTeachersBlocks: yourAbsentTeachers)
        
        var builder = TeacherSingleBlock.Builder()
        builder.name = textAndRoomNum.text
        builder.blockLetter = block.letter
        builder.blockNum = block.num
        builder.roomNum = textAndRoomNum.roomNum
        return TeacherWithBlock(teacher: builder.build(), block: block)
    }
    private func onSelectedDateChanged(newDate:LocalDate)
    {
        nextDate = newDate
        resetTable()
    }
    
    /*
     TABLE VIEW STUFF
     */
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return blocksForSection.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return blocksForSection[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:BlockNoRoomNumCell
        let teacherWithBlock = blocksForSection[indexPath.section][indexPath.row]
        if (teacherWithBlock.teacher.roomNum == nil)
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "blockNoRoomNumCell", for: indexPath) as! BlockNoRoomNumCell
        }
        else
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! BlockCell
        }
        cell.configure(teacher: teacherWithBlock)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let teacherWithBlock = blocksForSection[indexPath.section][indexPath.row]
        if (teacherWithBlock.teacher.roomNum == nil)
        {
            return 56
        }
        else
        {
            return 72
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return dateTextForSection[section]
    }
    //infinite scrolling (load new stuff once we almost reach the end)
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let actualPosition = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - tableView.frame.size.height
        if (actualPosition >= contentHeight)
        {
            populateBlocksWithNextDay()
        }
    }
}
