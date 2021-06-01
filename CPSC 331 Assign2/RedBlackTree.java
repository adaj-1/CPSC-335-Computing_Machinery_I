package ca.ucalgary.cpsc331;

/*
 * 
 */
class Node
{
	int key;							// 
	int colour; 						// 0 for red, 1 for black

	Node parent;
	Node leftChild;
	Node rightChild;	
}

/*
 * 
 */
public class RedBlackTree implements Dictionary{
	
	static final int RED = 0;
	static final int BLACK = 1;

	private Node tRoot;
	private Node tNil;
	
	/*
	 * Description: Red Black Tree Constructor. Initialized to empty tree.
	 */
	RedBlackTree()
	{
		tNil = new Node();					// creating new leaf/tNil node
		tNil.colour = BLACK;				// filling with tNil properties
		tNil.leftChild = null;
		tNil.rightChild = null;
		tRoot = tNil;						// initialize empty tree
	}
	
	/*
	 * Description: Iterative Tree Search algorithm find value within RBT
	 * 
	 * @param	value is searched for among the RBT keys
	 * 
	 * @returns	x the node which the value belongs to
	 */
	private Node iterativeTreeSearch(int value)
	{
		Node x = tRoot;							// start  search at root
		
		while (x != tNil && value != x.key)		// while value is not null or the root node TODO null
		{
			if (value < x.key)
			{
				x = x.leftChild;				// check left sub trees
			}
			else
			{
				x = x.rightChild;				// check right sub trees
			}
		}
		return x;
	}

	/*
	 * Description: to move subtrees around within the RBT
	 * 
	 * @param	deleted the subtree rooted at this node
	 * 			replace the subtree that was deleted
	 */
	private void rbTransplant(Node deleted, Node replace)
	{
		if (deleted.parent == tNil)							// handle if deleted subtree is root of  RBT TODO null
		{
			tRoot = replace;
		}
		else if (deleted == deleted.parent.leftChild)		// if deleted is a left child, update parent
		{
			deleted.parent.leftChild = replace;
		}
		else
		{
			deleted.parent.rightChild = replace;			// if deleted is a right child, update parent
		}
		
		replace.parent = deleted.parent;					// take parent of deleted and assign to replacement
	}
	
	/*
	 * Description: find the minimum  key in the RBT
	 * 
	 * @param	min given node to find the minimum element in subtree
	 * 
	 * @return	min nod that holds the minimum element
	 */
	private Node treeMinimum(Node min)
	{
		while (min.leftChild != tNil)		// RBT property guarantees finding tree minimum through leftchild
		{
			min = min.leftChild;
		}
		
		return min;
	}
	
	/*
	 * Description: checks if RBT is empty
	 * 
	 * TODO exception
	 */
	@Override
	public boolean empty() 
	{
		if(tRoot == tNil)
		{
			System.out.printf("tree is empty\n");				//TODO delete
			return true;
		}
		return false;
	}

	/*
	 * Description: restores Red-Black properties after rbInsert
	 * 
	 * @param	insertedNode to determine where to begin restoring RB properties
	 */
	private void rbInsertFixUp(Node insertedNode)
	{
		Node tmpNode;															
		
		/* while loop maintained if 
		 * a) insertedNode is red
		 * b) if insertedNode.parent is the root, then insertedNode.parent is black
		 * c) property 2 or property 4 is violated
		 */
		while (insertedNode.parent.colour == RED)		
		{		
			if (insertedNode.parent == insertedNode.parent.parent.leftChild)		// fixing right subtree
			{
				tmpNode = insertedNode.parent.parent.rightChild;
				
				if (tmpNode.colour == RED)
				{
					/* CASE 1 */
					insertedNode.parent.colour = BLACK;
					tmpNode.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					insertedNode = insertedNode.parent.parent;
				}
				else if (insertedNode == insertedNode.parent.rightChild)
				{
					/* CASE 2 */
					insertedNode = insertedNode.parent;
					leftRotate(insertedNode);
					
					/* CASE 3 */
					insertedNode.parent.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					rightRotate(insertedNode.parent.parent);
				}
			}
			else																	// fixing left subtree
			{
				tmpNode = insertedNode.parent.parent.leftChild;
				
				if (tmpNode.colour == RED)
				{
					/* CASE 1 */
					insertedNode.parent.colour = BLACK;			
					tmpNode.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					insertedNode = insertedNode.parent.parent;
				}
				else if (insertedNode == insertedNode.parent.leftChild)
				{
					/* CASE 2 */
					insertedNode = insertedNode.parent;
					rightRotate(insertedNode);
					
					/* CASE 3 */
					insertedNode.parent.colour = BLACK;
					insertedNode.parent.parent.colour = RED;
					leftRotate(insertedNode.parent.parent);
				}
			}
			
			if (insertedNode == tRoot)					// break out of loop if insertedNode becomes tRoot
			{
				break;
			}
		}	
		tRoot.colour = BLACK;							
	}

	/*
	 * Description: to insert a new value into the RBT
	 * 
	 * @param	key value to be inserted
	 */
	@Override
	public void insert(int key) 
	{
		Node insertedNode = new Node();			// initialize new node
		insertedNode.key = key;
		insertedNode.parent = tNil;	
		insertedNode.leftChild = tNil;
		insertedNode.rightChild = tNil;
		insertedNode.colour = RED;
		
		Node tmpNode = tNil;					// TODO set to null
		Node rootNode = tRoot;				// TODO set to this.tRoot

		while (rootNode != tNil)
		{
			tmpNode = rootNode;
			 
			if (insertedNode.key < rootNode.key)
			{
				rootNode = rootNode.leftChild;
			}
			else
			{
				rootNode = rootNode.rightChild;
			}
		}
		
		insertedNode.parent = tmpNode;
		
		if (tmpNode == tNil)					//TODO set to null
		{
			tRoot = insertedNode;
		}
		else if (insertedNode.key < tmpNode.key)
		{
			tmpNode.leftChild = insertedNode;
		}
		else
		{
			tmpNode.rightChild = insertedNode;
		}
		
				
		/* TODO 170-180 needs to be explained, directly copied from: https://www.programiz.com/dsa/red-black-tree*/
		if (insertedNode.parent == tNil)		//TODO set to null
		{
			insertedNode.colour = BLACK;
			return;
		}
		
		if (insertedNode.parent.parent == tNil)	//TODO set to null
		{
			return;
		}
		
		rbInsertFixUp(insertedNode);						// maintain property of red-black tree
	}
	
	private void leftRotate(Node rotate)
	{
		Node holdRotate = rotate.rightChild;			// set holdRotate
		rotate.rightChild = holdRotate.leftChild;		// turn holdRotate's left subtree into rotate's right subtree
		
		if (holdRotate.leftChild != tNil)
		{
			holdRotate.leftChild.parent = rotate;
		}
		
		holdRotate.parent = rotate.parent;				// links rotate's parents to holdRotate's
		
		if (rotate.parent == tNil)					//TODO set to null
		{
			this.tRoot = holdRotate;
		}
		else if (rotate == rotate.parent.leftChild)
		{
			rotate.parent.leftChild = holdRotate;
		}
		else
		{
			rotate.parent.rightChild = holdRotate;
		}
		
		holdRotate.leftChild = rotate;					// put rotate on holdRotate's left
		rotate.parent = holdRotate;
	}
	
	private void rightRotate(Node rotate)
	{
		Node holdRotate = rotate.leftChild;			// set holdRotate
		rotate.leftChild = holdRotate.rightChild;		// turn holdRotate's left subtree into rotate's right subtree
		
		if (holdRotate.rightChild != tNil)
		{
			holdRotate.rightChild.parent = rotate;
		}
		
		holdRotate.parent = rotate.parent;				// links rotate's parents to holdRotate's
		
		if (rotate.parent == tNil)						// TODO set to null
		{
			this.tRoot = holdRotate;
		}
		else if (rotate == rotate.parent.rightChild)
		{
			rotate.parent.rightChild = holdRotate;
		}
		else
		{
			rotate.parent.leftChild = holdRotate;
		}
		
		holdRotate.rightChild = rotate;					// put rotate on holdRotate's left
		rotate.parent = holdRotate;
	}
	
	private void rbDeleteFixUp(Node x)
	{
		Node w;
		
		while (x != tRoot &&  x.colour == BLACK)
		{
			if (x == x.parent.leftChild)
			{
				w = x.parent.rightChild;
				
				if (w.colour == RED)
				{
					w.colour = BLACK;
					x.parent.colour = RED;
					leftRotate(x.parent);
					w = x.parent.rightChild;
				}
				
				if (w.leftChild.colour == BLACK && w.rightChild.colour == BLACK)
				{
					w.colour = RED;
					x = x.parent;
				}
				else if (w.rightChild.colour == BLACK)
				{
					w.leftChild.colour = BLACK;
					w.colour = RED;
					rightRotate(w);
					w = x.parent.rightChild;
				}
				
				w.colour = x.parent.colour;
				x.parent.colour = BLACK;
				w.rightChild.colour = BLACK;
				leftRotate (x.parent);
				x = tRoot;
			}
			else
			{
				w = x.parent.leftChild; 
				
				if (w.colour == RED)
				{
					w.colour = BLACK;
					x.parent.colour = RED;
					rightRotate(x.parent);
					w = x.parent.leftChild;
				}
				
				if (w.rightChild.colour == BLACK && w.leftChild.colour == BLACK)
				{
					w.colour = RED;
					x = x.parent;
				}
				else if (w.leftChild.colour == BLACK)
				{
					w.rightChild.colour = BLACK;
					w.colour = RED;
					leftRotate(w);
					w = x.parent.leftChild;
				}
				
				w.colour = x.parent.colour;
				x.parent.colour = BLACK;
				w.leftChild.colour = BLACK;
				rightRotate (x.parent);
				x = tRoot;
			}
		}
		
		x.colour = BLACK;
	}
	
	@Override
	public void delete(int key) 
	{
		Node z = iterativeTreeSearch(key);
		
		Node y = z;
		Node x;
		
		int originalColour = y.colour;
		
		if (z.leftChild == tNil)
		{
			x =z.rightChild;
			rbTransplant(z, z.rightChild);
		}
		else if (z.rightChild == tNil)
		{
			x = z.leftChild;
			rbTransplant(z, z.leftChild);
		}
		else
		{
			y = treeMinimum(z.rightChild);
			originalColour = y.colour;
			x = y.rightChild;
			
			if (y.parent == z)
			{
				x.parent = y;
			}
			else
			{
				rbTransplant(y,y.rightChild);
				y.rightChild = z.rightChild;
				y.rightChild.parent = y;
			}
			rbTransplant(z, y);
			y.leftChild = z.leftChild;
			y.leftChild.parent = y;
			y.colour = z.colour;			
		}
		
		if (originalColour == BLACK)
		{
			rbDeleteFixUp(x);
		}
	}

	@Override
	public boolean member(int key) 
	{
		if (iterativeTreeSearch(key) != tNil)
		{
			System.out.printf("member is in tree\n");				//TODO delete
			return true;
		}
		return false;
	}
	
	/*
	 * Description: page 288 used for printing binary search tree in sorted order
	 * 	- visit and print the root node
	 * 	- transverse the left sub tree (recursively call  inorder( root > left)
	 * 	- transverse the right sub tree (recursively call inorder (root > right)
	 */
	private String preOrderTreeWalk(Node startingNode)
	{
		String addressColourKey = "";
		
		if(empty())									// returns empty string if tree is empty
		{
			return addressColourKey;
		}
		
		
			if (startingNode != null )
			{	
				String colour;
				if (startingNode.colour == 0)
				{
					colour = "red";
				}
				else
				{
					colour = "black";
				}
				
				addressColourKey ="*"+findAddress(startingNode)+":"+ colour +":" + startingNode.key ;
				
				if (startingNode != tNil) 
				{
				//System.out.printf("%s:%s:*%s\n", startingNode.key, colour, findAddress(startingNode));	
				System.out.printf("%s\n", addressColourKey);
				}
				
				preOrderTreeWalk(startingNode.leftChild);
				preOrderTreeWalk(startingNode.rightChild);
			}
			
	
		
		return addressColourKey;
	}
	
	private String findAddress(Node node)
	{
		String address = "";						// starting at root
		
		Node tmp = node;
		
		while (tmp != tRoot && tmp.parent != null)
		{
			if (tmp == tmp.parent.rightChild)		// check if node is right child of root
			{
				address = address.concat("R");
			}
			else
			{
				address = address.concat("L");
			}
			tmp = tmp.parent;	
		}
		
		//CITATION: https://devqa.io/reverse-string-java/
		String finalAddress = "";
		
		for (char c : address.toCharArray())			// reversing string for final address
		{
			finalAddress = c + finalAddress;
		}
				
		return finalAddress;
	}
	
	@Override
	public String toString()
	{
		Node startingNode = tRoot;
	
		String addressColourKey = preOrderTreeWalk(startingNode);
		
		return addressColourKey;	
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
