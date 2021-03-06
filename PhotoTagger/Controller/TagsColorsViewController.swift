/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class TagsColorsViewController: UIViewController {

  // MARK: - Properties
  var tags: [String]?
  var colors: [PhotoColor]?
  var tableViewController: TagsColorsTableViewController?

  // MARK: - IBOutlets
  @IBOutlet var segmentedControl: UISegmentedControl!
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    setupTableData()
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "DataTable" {
      tableViewController = segue.destination as? TagsColorsTableViewController
    }
  }

  // MARK: - IBActions
  @IBAction func tagsColorsSegmentedControlChanged(_ sender: UISegmentedControl) {
    setupTableData()
  }

  // MARK: - Public
  func setupTableData() {
    if segmentedControl.selectedSegmentIndex == 0 {

      if let tags = tags {
        let data = tags.map {
          TagsColorTableData(label: $0, color: nil)
        }
        tableViewController?.data = data
      } else {
        tableViewController?.data = [TagsColorTableData(label: "No tags were fetched.", color: nil)]
      }
    } else {
      if let colors = colors {
        tableViewController?.data = colors.map({ (photoColor: PhotoColor) -> TagsColorTableData in
          let uicolor = UIColor(red: CGFloat(photoColor.red!) / 255,
                                green: CGFloat(photoColor.green!) / 255,
                                blue: CGFloat(photoColor.blue!) / 255,
                                alpha: 1.0)
          return TagsColorTableData(label: photoColor.colorName!, color: uicolor)
        })
      } else {
        tableViewController?.data = [TagsColorTableData(label: "No colors were fetched.", color: nil)]
      }
    }

    tableViewController?.tableView.reloadData()
  }
}
