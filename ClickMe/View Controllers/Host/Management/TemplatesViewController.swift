//
//  TemplatesViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-06.
//

import UIKit

class TemplatesViewController: BaseViewController {
    @IBOutlet weak var tableview: UITableView!
    
    private var templates: [Template]? {
        didSet {
            tableview.reloadData()
            noResultsViewContainer.isHidden = !(templates?.isEmpty ?? true)
        }
    }
    private var selected: Template?
    
    override func setup() {
        super.setup()
        
        errorView.configureUI(style: .noData)
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
        tableview.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchTemplates()
    }

    @objc func duplicatePressed(sender: UIButton) {
        guard let template = templates?[sender.tag] else { return }
        
        FullScreenSpinner().show()
        
        api.duplicateTemplate(templateId: template.identifier) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                self.templates = response
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                error.showErrorDialog()
            }
        }
    }
    
    @objc func deletePressed(sender: UIButton) {
        guard let template = templates?[sender.tag] else { return }
        
        FullScreenSpinner().show()
        
        api.deleteTemplate(templateId: template.identifier) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                self.templates = response
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                error.showErrorDialog()
            }
        }
    }
    
    @objc func usePressed(sender: UIButton) {
        guard let template = templates?[sender.tag] else { return }
        
        selected = template
        performSegue(withIdentifier: "goToNewSchedule", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNewSchedule",
           let vc = segue.destination as? EditTopicViewController,
           let template = selected {
            vc.mode = .fromTemplate(template)
        }
    }
    
    private func fetchTemplates() {
        templates == nil ? FullScreenSpinner().show() : nil
        api.getTemplates { [weak self]  result in
            guard let self = self else { return }
            
            self.templates == nil ? FullScreenSpinner().hide() : nil
            
            switch result {
            case .success(let response):
                self.templates = response
            case .failure(let error):
                guard let _ = error.responseCode else {
                    showNetworkErrorDialog()
                    return
                }
                
                error.showErrorDialog()
            }
        }
    }
}

extension TemplatesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateTableViewCell", for: indexPath) as? TemplateTableViewCell, let template = templates?[indexPath.row] else {
            return TemplateTableViewCell()
        }
        cell.config(data: template)
        cell.deleteButton.tag = indexPath.row
        cell.duplicateButton.tag = indexPath.row
        cell.useButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
        cell.duplicateButton.addTarget(self, action: #selector(duplicatePressed), for: .touchUpInside)
        cell.useButton.addTarget(self, action: #selector(usePressed), for: .touchUpInside)
        return cell
    }
}
